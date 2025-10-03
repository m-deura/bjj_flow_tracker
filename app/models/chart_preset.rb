class ChartPreset < ApplicationRecord
  # ユーザー所有のチャートが削除される可能性が高いため、dependent: :destroyは行わない
  has_many :charts, dependent: :restrict_with_exception
  has_many :node_presets, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
