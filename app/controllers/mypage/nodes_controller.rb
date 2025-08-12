class Mypage::NodesController < Mypage::BaseController
  def new
    @chart = current_user.charts.find(params[:chart_id])
    exclude_ids = @chart.nodes.roots.pluck(:technique_id)
    @candidate_techniques = current_user.techniques.where.not(id: exclude_ids)
    @node = @chart.nodes.build
  end

  def create
    @chart = current_user.charts.find(params[:chart_id])
    @node = @chart.nodes.build(create_params)

    if @node.save
      redirect_to mypage_chart_path(@chart), notice: "フローの開始点を作成しました"
    else
      flash.now[:alert] = "保存できませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @node = current_user.nodes.find(params[:id])
    @chart = @node.chart
    @technique = @node.technique

    @children = @node.children.includes(:technique)
    siblings = @node.siblings.includes(:technique)
    exclude_ids = [ @technique.id ] + @children.pluck(:technique_id) + siblings.pluck(:technique_id)
    @candidate_techniques = current_user.techniques.where.not(id: exclude_ids)
  end

  def update
    @node = current_user.nodes.find(params[:id])
    chart = @node.chart
    # technique = @node.technique

    selected_ids = Array(update_params[:children_ids])
    current_ids = @node.children.pluck(:technique_id)

    ids_to_add = selected_ids - current_ids
    ids_to_remove = current_ids - selected_ids

    Node.transaction  do
      ids_to_add.each do |tid|
        @node.children.create!(
          chart: chart,
          technique_id: tid
        )
      end
      @node.children.where(technique_id: ids_to_remove).destroy_all
    end

    # 子ノード追加時にtransitionを更新する
    # ids_to_add.each do |tid|
    #  technique.outgoing_transitions.find_or_create_by!(
    #    user: current_user,
    #    to_technique_id: tid
    #  )
    # end
    # ids_to_remove.each do |tid|
    #  technique.outgoing_transitions.where(to_technique_id: tid).destroy_all
    # end

    redirect_to mypage_chart_path(chart), notice: "展開先テクニックを更新しました", status: :see_other
  end

  def destroy
    node = current_user.nodes.find(params[:id])
    chart = node.chart
    node.destroy!
    redirect_to mypage_chart_path(chart), notice: "ノードを削除しました", status: :see_other
  end

  private

  def create_params
    params.require(:node).permit(:technique_id)
  end

  def update_params
    # 展開先テクニックに何も選択されていない状態で更新をかけるとparams[:node]自体が送られないので、空配列も許容する。
    params.fetch(:node, {}).permit(children_ids: [])
  end
end
