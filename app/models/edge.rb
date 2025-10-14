class Edge < ApplicationRecord
  belongs_to :from, class_name: "Node", inverse_of: :outgoing_edges
  belongs_to :to, class_name: "Node", inverse_of: :incoming_edges

  # has_one :chart, through: :from, source: :chart

  validates :flow, presence: true

  # typed_dagがedgeを自動生成するため、edgesテーブルに chart_id を設けることができない。
  # その代わり、delegate で from(Nodeインスタンス)しか持っていない関連chartメソッドを使えるようにする
  # = Edge.first.chart と Edge.first.chart_id が使えるようになる
  delegate :chart, :chart_id, to: :from
end
