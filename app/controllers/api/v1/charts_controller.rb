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

    # ancestry
    # edges_data = nodes.map do |node|
    #  if node.has_parent?
    #    { source: node.parent_id.to_s, target: node.id.to_s }
    #  end
    # end.compact # has_parent?に該当しないnodeはnilを返すため、これを排除する。

    # typed_dag
    # typed_dag により edgeレコードは自動管理されるため、edgesテーブルの関連に chart_id を設けることができない。＝ chart.edges でチャート単位のエッジを直接取得できない。
    # そのため、「チャート上にあるノードを接続するエッジ」を以下の記述にて抽出することで代替する。
    node_ids = nodes.select(:id)
    edges = Edge.where(flow: 1, from_id: node_ids)
              .or(Edge.where(flow: 1, to_id: node_ids))
              .distinct

    # 本エッジ
    flow_edges_data = edges.map do |edge|
      next if edge.from_id == edge.to_id
      {
        source: edge.from_id.to_s,
        target: edge.to_id.to_s,
        data: { kind: "flow" }
      }
    end.compact # nextでスキップされたedgeはnilを返すため、これを排除する。

    # 循環を示す逆走エッジ
    #   - technique_id ごとにまとめ、id昇順で隣接連結（n個なら n-1 本）
    reverse_edges_data = []
    groups = nodes.group_by(&:technique_id)
    groups.each_value do |g|
      next if g.size < 2
      g.sort_by!(&:created_at)
      oldest = g.first
      g.drop(1).each do |n|
        reverse_edges_data << {
          source: n.id.to_s,
          target: oldest.id.to_s,
          data:   { kind: "reverse" }
        }
      end
    end

    render json: {
      nodes: nodes_data,
      edges: flow_edges_data + reverse_edges_data
      }, status: :ok
  end
end
