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
    parent_technique.outgoing_transitions.find_or_create_by!(
      to_technique: child_technique,
      user: current_user
    )

    redirect_to edit_mypage_node_path(parent_node), notice: "子ノードを追加しました"
  end

  def edit
    @node = current_user.nodes.find(params[:id])
    @chart = @node.chart
    @technique = @node.technique

    @children = @node.children.includes(:technique)
    exclude_ids = [ @technique.id ] + @children.pluck(:technique_id)
    @candidate_techniques = current_user.techniques.where.not(id: exclude_ids)
  end

  def update
    @node = current_user.nodes.find(params[:id])
    chart = @node.chart

    selected_ids = Array(update_params[:children_ids]).map(&:to_i)
    current_ids = @node.children.pluck(:technique_id)

    ids_to_add = selected_ids - current_ids
    ids_to_remove = current_ids - selected_ids

    ids_to_add.each do |tid|
      @node.children.create!(
        chart: chart,
        technique_id: tid
      )
    end

    @node.children.where(technique_id: ids_to_remove).destroy_all

    redirect_to mypage_chart_path(chart), notice: "展開先テクニックを更新しました", status: :see_other
  end

  def destroy
    node = current_user.nodes.find(params[:id])
    chart = node.chart
    node.destroy!
    redirect_to mypage_chart_path(chart), notice: "ノードを削除しました", status: :see_other
  end

  private

  def update_params
    params.require(:node).permit(children_ids: [])
  end
end
