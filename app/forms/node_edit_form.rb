class NodeEditForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  # ---- 属性 ----
  # ノードとユーザーはコンストラクタで受け取り、操作対象を決める
  attr_reader :node, :current_user

  # Techniqueの編集項目
  attribute :name, :string
  attribute :note, :string
  attribute :category, :string
  attribute :children, default: [] # ["1", "2", "new: XX"] のような配列

  # triggers は { "1" => "A→B", "new: XX" => "C→D" } のように、"children の各要素" をキーにしたハッシュで受け取る
  attr_accessor :triggers

  validates :name, presence: true

  # ====== 初期化 ======
  def initialize(node:, current_user:, **attrs)
    @node = node
    @current_user = current_user

    # attribute で定義した項目に attrs(node_edit_form_params) の値を一括で流し込み・型変換。
    # 例：attrs[:children] が来ていれば、それがまず self.children に入る。
    super(attrs)

    # 初期表示用にTechniqueから値を埋めておく（attrs があれば優先）
    self.name ||= technique.name_for
    self.note ||= technique.note
    self.category ||= technique.category
    self.children = normalize_children(self.children.presence || node.dag_children.pluck(:technique_id).map(&:to_s))
    self.triggers = normalize_triggers(self.triggers)

    # フォーム初期表示（paramsが無い）なら、既存エッジの trigger を「technique_id文字列 => trigger」で埋める
    if self.triggers.blank?
      child_ids = node.dag_children.pluck(:technique_id)
      # to側ノードをJOINして、technique_id と edge.trigger を一発で取得
      pairs = Edge
                .joins("JOIN nodes AS to_nodes ON to_nodes.id = edges.to_id")
                .where(edges: { flow: 1, from_id: node.id },
                       to_nodes: { technique_id: child_ids })
                .pluck("to_nodes.technique_id", "edges.trigger")
      # { "tech_id(文字列)" => "trigger" } に整形
      self.triggers = pairs.to_h.transform_keys { |tid| tid.to_s }.compact
    end
  end

  # 保存処理
  def save
    ActiveRecord::Base.transaction do
      # 1) Techniqueの更新
      technique.assign_attributes(
        note: note,
        category: category
      )
      technique.set_name_for(name, I18n.locale)

      unless technique.save
        propagate_errors_from(technique)
        raise ActiveRecord::Rollback
      end

      # 2) 子ノード（展開先）の更新
      selected_ids, trigger_map = resolve_selected_technique_ids(children, triggers)
      current_ids = node.dag_children.pluck(:technique_id)

      ids_to_add    = selected_ids - current_ids
      ids_to_remove = current_ids - selected_ids
      ids_to_update = selected_ids & current_ids

      sync!(node: node,
            ids_to_add: ids_to_add,
            ids_to_remove: ids_to_remove,
            ids_to_update: ids_to_update,
            trigger_map: trigger_map
           )
    end

    errors.empty?
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  rescue StandardError => e
    # フォームオブジェクトではtメソッドが未定義
    errors.add(:base, "#{I18n.t('defaults.flash_messages.not_updated', item: Node.model_name.human)}: #{e.message}")
    false
  end

  private

  def technique
    # メモ化
    @technique ||= node.technique
  end

  # nil安全・文字列化
  def normalize_children(arr)
    Array(arr).map(&:to_s)
  end

  def normalize_triggers(h)
    (h || {}).to_h { |k, v| [ k.to_s, v.to_s ] }
  end

  # "new: ○○" は作成。既存IDはそのまま採用。
  def resolve_selected_technique_ids(raw_children, raw_triggers)
    key_to_id = {} # "1"(technique_id) or "new: XXX" : technique_id(Integer)

    new_names, existing_ids = [], []
    normalize_children(raw_children).each do |val|
      if val.start_with?("new: ")
        new_names << val.sub(/^new: /, "")
      elsif val.present?
        existing_ids << val.to_i
      end
    end

    # 既存テクニック
    existing_ids.each { |tid| key_to_id[tid.to_s] = tid }

    # 新規テクニック
    # 現ロケールのカラムのみに値を入れる（もう片方はモデルの作成時補完に委ねる）
    field = Technique.name_field_for(I18n.locale) # :name_ja or :name_en
    new_names.map do |n|
      # キーがリテラルでないので、シンボル記法(:)ではなくロケット記法(=>)
      t = current_user.techniques.find_or_create_by!(field => n).id
      key_to_id["new: #{n}"] = t.id
    end

    selected_ids = key_to_id.values.uniq

    # triggers は「元キー」ベースで来るので technique_id にマップし直す
    # { technique_id: triigerカラムの内容 }
    trigger_map = {}
    normalize_triggers(raw_triggers).each do |raw_key, trig|
      tid = key_to_id[raw_key]
      trigger_map[tid] = trig if tid.present? # "" も含まれる
    end

    [ selected_ids, trigger_map ]
  end

  def propagate_errors_from(record)
    record.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end

  def sync!(node:, ids_to_add:, ids_to_remove:, ids_to_update:, trigger_map:)
    Node.transaction do
      add_children!(node, ids_to_add, trigger_map)
      update_edge_triggers!(node, ids_to_update, trigger_map)
      remove_children!(node, ids_to_remove)
    end
  end

  def add_children!(node, tech_ids, trigger_map)
    return if tech_ids.blank?

    # ancestry: 追加（親が一つしか持てない関係上、集約させたいノードであっても新規作成してしまう(typed_dagと並行運用できない)ので、コメントアウト）
    # tech_ids.each do |tid|
    #  node.children.find_or_create_by!(
    #    chart: node.chart,
    #    technique_id: tid
    #  )
    # end

    tech_ids.uniq.each do |tid|
      # binding.pry
      # 同一チャート×同一テクの既存候補（自分自身は除外）
      candidates = Node.where(chart_id: node.chart_id, technique_id: tid)

      # 親 node に到達可能な「blocked child 候補」の id を収集
      # ここでの Edge は transitive を含む（from_id: child, to_id: parent）
      blocked_ids = Edge.where(to_id: node.id).select(:from_id)

      # サイクルにならない既存ノード群
      safe_existing = candidates.where.not(id: blocked_ids)

      # 作成日時が最新の1件と接続
      child = safe_existing.order(created_at: :desc).first

      # サイクルにならないノードがない場合は新規作成
      child ||= Node.create!(chart_id: node.chart_id, technique_id: tid)

      # 直辺を張る（重複回避）
      edge = Edge.find_or_create_by!(flow: 1, from_id: node.id, to_id: child.id)

      if trigger_map[tid].key?
        new_val = trigge_map[tid].presence
        edge.update!(trigger: new_val) if edge.trigger != new_val
      end
    end
  end

  # 未使用メソッド(過去使用していたものを念の為保存)
  def dag_cycle?(parent:, child:)
    parent.ancestors.exists?(id: child.id)
  end

  def update_edge_triggers!(node, tech_ids, trigger_map)
    nil if tech_ids.blank? || trigger_map.blank?

    #
    edges = Edge.joins("JOIN nodes AS to_nodes ON to_nodes.id = edges.to_id")
              .where(edges: { flow: 1, from_id: node.id },
                     to_nodes: { technique_id: tech_ids })

    edges.find_each do |edge|
      tid = Node.where(id: edge.to_id).pick(:technique_id)
      next unless tid

      # ユーザーがその行を編集したかをkey?で判定
      next unless trigger_map.key?(tid)

      new_val = trigger_map[tid].presence  # "" は nil に変換される
      next if edge.trigger == new_val

      edge.update!(trigger: trigger_map[tid])
    end
  end

  def remove_children!(node, tech_ids)
    return if tech_ids.blank?

    # ancestry: 削除
    node.children.where(technique_id: tech_ids).destroy_all

    # typed_dag：直辺のみ削除
    targets = Node.where(chart_id: node.chart_id, technique_id: tech_ids)
    Edge.where(from_id: node.id, to_id: targets.select(:id), flow: 1).delete_all
    # エッジ削除時、推移辺は自動削除されない様子なので再計算
    Node.rebuild_dag!
  end
end
