class NodePreset < ApplicationRecord
  belongs_to :chart_preset
  belongs_to :technique_preset
  has_many :outgoing_edges, class_name: "EdgePreset", foreign_key: "from_id", dependent: :destroy
  has_many :incoming_edges, class_name: "EdgePreset", foreign_key: "to_id", dependent: :destroy
end
