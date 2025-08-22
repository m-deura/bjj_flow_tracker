class Technique < ApplicationRecord
  belongs_to :user
  belongs_to :technique_preset, optional: true
  has_many :nodes, dependent: :destroy

  before_validation :fill_name_en_from_ja

  validates :name_ja, presence: true, uniqueness: { scope: :user_id }
  validates :name_en, presence: true, uniqueness: { scope: :user_id, case_sensitive: false },
    # テクニック名の制約に抵触した際、name_jaとname_enのエラーが双方表示されることを防ぐ
    unless: -> { (name_ja.blank? && name_en.blank?) || (name_en.present? && name_en == name_ja) }

  enum :category, { submission: 0, sweep: 1, pass: 2, guard: 3, control: 4,  takedown: 5 }

  def self.ransackable_associations(auth_object = nil)
    [ "user" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "name_ja", "name_en", "note" ]
  end

  private

  # name_en の NOT NULL制約回避
  def fill_name_en_from_ja
    self.name_en = name_ja if name_en.blank?
  end
end
