class Chart < ApplicationRecord
  belongs_to :user
  belongs_to :chart_preset, optional: true
  has_many :nodes, dependent: :destroy

  # outgoing_edges を through でたどる。
  # 重複を避けるため、from 側だけを持ってくる（distinct は念の為）
  has_many :edges, -> { distinct }, through: :nodes, source: :outgoing_edges

  validates :name, presence: true, uniqueness: { scope: :user_id }

  def self.ransackable_attributes(auth_object = nil)
    [ "name" ]
  end
end
