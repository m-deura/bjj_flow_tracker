class Technique < ApplicationRecord
  #  belongs_to :template_technique
  belongs_to :user

  validates :name, presence: true, uniqueness: true
  validates :mastery_level, presence: true
  validates :is_submission, inclusion: { in: [ true, false ] }
  validates :is_bookmarked, inclusion: { in: [ true, false ] }

  enum :mastery_level, { not_learned: 0, familiar: 1, practicing: 2, almost_there: 3, perfect: 4 }
end
