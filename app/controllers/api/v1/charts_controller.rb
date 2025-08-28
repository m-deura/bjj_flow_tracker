class Api::V1::ChartsController < ApplicationController
  def show
    nodes = current_user.charts.first.nodes.order(:created_at)

    nodes_data = nodes.map do |node|
      { data: { id: node.id.to_s, label: node.technique.name_ja, category: node.technique.category } }
    end

    edges_data = nodes.map do |node|
      if node.has_parent?
        { data: { source: node.parent_id.to_s, target: node.id.to_s } }
      end
    end.compact # has_parent?に該当しないnodeはnilを返すため、これを排除する。

    render json: (nodes_data + edges_data), status: :ok
  end
end
