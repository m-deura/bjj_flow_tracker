class Transition < ApplicationRecord
  belongs_to :from, class_name: "Technique", inverse_of: :outgoing_transitions
  belongs_to :to, class_name: "Technique", inverse_of: :incoming_transitions

  validates :from_id, :to_id, presence: true
end
