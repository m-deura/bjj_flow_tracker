class NodePreset < ApplicationRecord
  belongs_to :chart_preset
  belongs_to :technique_preset
  has_ancestry ancestry_format: :materialized_path2
end
