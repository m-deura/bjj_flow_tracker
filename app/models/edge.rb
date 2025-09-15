class Edge < ApplicationRecord
  belongs_to :from_node, class_name: "Node"
  belongs_to :to_node, class_name: "Node"
  validates :flow, presence: true
end
