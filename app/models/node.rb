class Node < ApplicationRecord
  belongs_to :chart
  belongs_to :technique
  has_many :outgoing_edges, class_name: "Edge", foreign_key: :from_id, inverse_of: :from, dependent: :destroy
  has_many :incoming_edges, class_name: "Edge", foreign_key: :to_id, inverse_of: :to, dependent: :destroy
end
