class Edge < ApplicationRecord
  belongs_to :from, class_name: "Node", inverse_of: :outgoing_edges
  belongs_to :to, class_name: "Node", inverse_of: :incoming_edges

  # has_one :chart, through: :from, source: :chart

  validates :flow, presence: true
end
