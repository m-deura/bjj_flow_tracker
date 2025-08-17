class TechniquePreset < ApplicationRecord
  has_many :techniques

  validates :name_ja, presence: true, uniqueness: true
  validates :name_en, presence: true, uniqueness: true

  enum :category, { submission: 0, sweep: 1, pass: 2, guard: 3, control: 4, takedown: 5 }
end
