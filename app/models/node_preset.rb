class NodePreset < ApplicationRecord
  belongs_to :chart_preset
  belongs_to :technique_preset
end
