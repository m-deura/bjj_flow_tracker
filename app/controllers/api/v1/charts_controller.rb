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

    # ノードに紐づく直辺エッジのみを取得
    edges = Edge.where(flow: 1, from_id: node_ids)
              .or(Edge.where(flow: 1, to_id: node_ids))
              .distinct

    # エッジを始点としてノードを経由し、transitionsテーブルのtriggerカラムを取得
    edge_with_triggers = edges.joins(<<~SQL)
      JOIN nodes AS from_nodes ON from_nodes.id = edges.from_id
      JOIN nodes AS to_nodes ON to_nodes.id = edges.to_id
      LEFT OUTER JOIN transitions
        ON transitions.from_id = from_nodes.technique_id
        AND transitions.to_id = to_nodes.technique_id
      SQL
      .select(
        "edges.from_id AS from_id",
        "edges.to_id AS to_id",
        "COALESCE(transitions.trigger, '') AS trigger"
      )

    # 本エッジ
    flow_edges_data = edge_with_triggers.map do |row|
      {
        source: row.from_id.to_s,
        target: row.to_id.to_s,
        data: {
          kind: "flow",
          trigger: row.trigger.to_s
        }
      }
    end

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
