class TechniquePreset < ApplicationRecord
  # ユーザー所有のテクニックが削除される可能性が高いため、dependent: :destroyは行わない
  has_many :techniques, dependent: :restrict_with_exception
  has_many :node_presets, dependent: :destroy

  validates :name_ja, presence: true, uniqueness: true
  validates :name_en, presence: true, uniqueness: true

  enum :category, { submission: 0, sweep: 1, pass: 2, guard: 3, control: 4, takedown: 5 }
end
