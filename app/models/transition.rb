class Transition < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :from_technique, class_name: "Technique"
  belongs_to :to_technique, class_name: "Technique"

  validates :from_technique, uniqueness: { scope: :to_technique }
end
