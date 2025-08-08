class Mypage::NodesController < Mypage::BaseController
  def new
  end

  def create
    # p params
    parent_node = current_user.nodes.find(params[:parent_node_id])
    chart = parent_node.chart

    child_node = chart.nodes.create!(
      technique_id: params[:technique_id],
      parent: parent_node
    )

    parent_technique = parent_node.technique
    child_technique = child_node.technique
    parent_technique.outgoing_transitions.create!(
      to_technique: child_technique,
      user: current_user
    )

    redirect_to edit_mypage_node_path(parent_node), notice: "子ノードを追加しました"
  end

  def edit
    @node = current_user.nodes.find(params[:id])
    @chart = @node.chart
    @technique = @node.technique
    @techniques = current_user.techniques.where.not(id: @technique.id)
  end

  def update
    @node = current_user.nodes.find(params[:id])
    @chart = @node.chart
    @technique = @node.technique
  end

  def destroy
    node = current_user.nodes.find(params[:id])
    chart = node.chart
    node.destroy!
    redirect_to mypage_chart_path(chart), notice: "ノードを削除しました"
  end

  private

  def technique_params
    params.require(:technique).permit(:id, :name, :note, :category, outgoing_transitions_attributes: [ :id, :to_technique_id, :trigger, :_destroy ])
  end
end
