class Api::V1::ChartsController < ApplicationController
  def show
    chart = current_user.charts.find(params[:id])
    nodes = chart.nodes.includes(:technique)
    nodes_data = nodes.map do |node|
      {
        id:        node.id.to_s,
        data: {
          label:     node.technique&.name_for.to_s,
          category:  node.technique&.category.presence
        }
      }
    end

    edges_data = nodes.map do |node|
      if node.has_parent?
        { source: node.parent_id.to_s, target: node.id.to_s }
      end
    end.compact # has_parent?に該当しないnodeはnilを返すため、これを排除する。

    render json: { nodes: nodes_data, edges: edges_data }, status: :ok
  end
end
