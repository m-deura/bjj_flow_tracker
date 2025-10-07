class Edge < ApplicationRecord
  belongs_to :from, class_name: "Node"
  belongs_to :to, class_name: "Node"
  validates :flow, presence: true
end
