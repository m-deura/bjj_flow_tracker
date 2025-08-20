class Technique < ApplicationRecord
  belongs_to :user
  belongs_to :technique_preset, optional: true
  has_many :nodes, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id }
  # validates :mastery_level, presence: true
  # validates :is_bookmarked, inclusion: { in: [ true, false ] }

  enum :category, { submission: 0, sweep: 1, pass: 2, guard: 3, control: 4,  takedown: 5 }
  # enum :mastery_level, { not_learned: 0, familiar: 1, practicing: 2, almost_there: 3, perfect: 4 }

  def self.ransackable_associations(auth_object = nil)
    [ "user" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "name", "note" ]
  end
end
