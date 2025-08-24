class Chart < ApplicationRecord
  belongs_to :user
  belongs_to :chart_preset, optional: true
  has_many :nodes, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
