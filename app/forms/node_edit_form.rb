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

  # UIから受け取る情報
  attribute :children, default: [] # ["1", "2", "new: XX"] のような配列

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
  end

  # 画面→保存 本体
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
      selected_ids = resolve_selected_technique_ids(children)
      current_ids = node.dag_children.pluck(:technique_id)

      ids_to_add    = selected_ids - current_ids
      ids_to_remove = current_ids - selected_ids

      sync!(node: node, ids_to_add: ids_to_add, ids_to_remove: ids_to_remove)
    end

    errors.empty?
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  rescue StandardError => e
    errors.add(:base, "更新に失敗しました: #{e.message}")
    false
  end

  private

  def technique
    # メモ化
    @technique ||= node.technique
  end

  def normalize_children(arr)
    Array(arr).map(&:to_s) # nil安全・文字列化
  end

  # "new: ○○" は作成・既存IDはそのまま採用
  def resolve_selected_technique_ids(raw_children)
    new_names, existing_ids = [], []
    normalize_children(raw_children).each do |val|
      if val.start_with?("new: ")
        new_names << val.sub(/^new: /, "")
      elsif val.present?
        existing_ids << val.to_i
      end
    end

    # 現ロケールのカラムのみに値を入れる（もう片方はモデルの作成時補完に委ねる）
    field = Technique.name_field_for(I18n.locale) # :name_ja or :name_en
    new_ids = new_names.map do |n|
      # キーがリテラルでないので、シンボル記法(:)ではなくロケット記法(=>)
      current_user.techniques.find_or_create_by!(field => n).id
    end
      (existing_ids.compact + new_ids).uniq
  end

  def propagate_errors_from(record)
    record.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end

  def sync!(node:, ids_to_add:, ids_to_remove:)
    Node.transaction do
      add_children!(node, ids_to_add)
      remove_children!(node, ids_to_remove)
    end
  end

  def add_children!(node, tech_ids)
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
      Edge.find_or_create_by!(flow: 1, from_id: node.id, to_id: child.id)
    end
  end

  # 未使用メソッド(過去使用していたものを念の為保存)
  def dag_cycle?(parent:, child:)
    parent.ancestors.exists?(id: child.id)
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
