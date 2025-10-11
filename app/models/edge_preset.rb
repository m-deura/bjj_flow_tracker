class EdgePreset < ApplicationRecord
  belongs_to :from, class_name: "NodePreset"
  belongs_to :to, class_name: "NodePreset"
end
