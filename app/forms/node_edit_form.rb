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
    super(attrs)

    # 初期表示用にTechniqueから値を埋めておく（attrs があれば優先）
    self.name ||= technique.name_for
    self.note    ||= technique.note
    self.category ||= technique.category
    self.children = normalize_children(self.children.presence || node.children.pluck(:technique_id).map(&:to_s))
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
      current_ids = node.children.pluck(:technique_id)

      ids_to_add    = selected_ids - current_ids
      ids_to_remove = current_ids - selected_ids

      # 追加
      ids_to_add.each do |tid|
        node.children.find_or_create_by!(
          chart: node.chart,
          technique_id: tid
        )
      end
      # 削除
      node.children.where(technique_id: ids_to_remove).destroy_all
    end

    errors.empty?
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  rescue StandardError => e
    errors.add(:base, "更新に失敗しました: #{e.message}")
    false
  end

  # 表示用：セレクトの選択済み値を返す
  def selected_children_ids
    node.children.pluck(:technique_id).map!(&:to_s)
  end

  private

  def technique
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
end
