class Technique < ApplicationRecord
  belongs_to :user
  belongs_to :technique_preset, optional: true
  has_many :nodes, dependent: :destroy

  before_validation :populate_missing_name, on: :create

  validates :name_ja, presence: true, uniqueness: { scope: :user_id }
  validates :name_en, presence: true, uniqueness: { scope: :user_id, case_sensitive: false },
    # name_ja と同値の時は name_en のユニーク検証をスキップ（重複エラーの二重表示を防止）
    unless: -> { (name_ja.blank? && name_en.blank?) || (name_en.present? && name_en == name_ja) }

  enum :category, { submission: 0, sweep: 1, pass: 2, guard: 3, control: 4,  takedown: 5 }

  attr_accessor :name  # フォーム用の仮想属性

  # 関連では検索させない
  def self.ransackable_associations(auth_object = nil)
    []
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "name_ja", "name_en", "note", "category" ]
  end

  LOCALE_NAME_FIELD = { ja: :name_ja, en: :name_en }.freeze

  # ロケール→カラム名
  def self.name_field_for(loc = I18n.locale)
    LOCALE_NAME_FIELD[loc.to_sym] ||
      LOCALE_NAME_FIELD[I18n.default_locale] || :name_ja
  end

  # 表示用
  def name_for(loc = I18n.locale)
    case loc.to_sym
    when :en
      name_en.presence
    else
      name_ja.presence
    end
  end

  # 保存用
  def set_name_for(value, loc = I18n.locale)
    primary   = self.class.name_field_for(loc)
    secondary = (primary == :name_ja ? :name_en : :name_ja)

    # 1) まず現在ロケールの列を更新
    self[primary] = value

    # 2) プリセット由来のテクニックは、secondaryを更新しない
    if technique_preset_id.blank?
      self[secondary] = value
    end

    save
  end

  private

  # name_{ja,en} の NOT NULL制約回避
  def populate_missing_name
    if name_ja.blank? && name_en.present?
      self.name_ja = name_en
    elsif name_en.blank? && name_ja.present?
      self.name_en = name_ja
    end
  end
end
