class Mypage::NodesController < ApplicationController
  def new
    @chart = current_user.charts.find(params[:chart_id])
    exclude_ids = @chart.nodes.roots.pluck(:technique_id)
    @candidate_techniques = current_user.techniques.where.not(id: exclude_ids)

    @grouped = @candidate_techniques
        .group_by { |t| t.category ? t.category.humanize : "未分類" }
        .transform_values { |arr| arr.map { |t| [ t.name_ja, t.id ] } }
  end

  def create
    @chart = current_user.charts.find(params[:chart_id])

    begin
      ActiveRecord::Base.transaction do
        roots = Array(create_params[:roots])
        raise ArgumentError, "フローの開始点を1つ以上選択してください" if roots.empty?

        new_names = []
        existing_ids = []

        roots.each do |root|
          if root.to_s.start_with?("new: ")
            new_names << root.sub(/^new: /, "")
          else
            existing_ids << root.to_i
          end
        end

        new_ids = new_names.map do |name|
          current_user.techniques.create!(name_ja: name, name_en: name).id
        end

        ids_to_add = existing_ids + new_ids
        ids_to_add.each do |tid|
          Node.create!(
            chart: @chart,
            technique_id: tid
          )
        end
      end

      redirect_to mypage_chart_path(@chart), notice: "フローの開始点を作成しました"

    rescue ArgumentError => e
      flash[:alert] = e.message
      redirect_to mypage_chart_path(@chart)
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = e.message
      redirect_to mypage_chart_path(@chart)
    rescue StandardError => e
      flash[:alert] = "フローの開始点を作成できませんでした"
      redirect_to mypage_chart_path(@chart)
    end
  end

  def edit
    @node = current_user.nodes.find(params[:id])
    @chart = @node.chart
    @technique = @node.technique
    @children = @node.children.includes(:technique)

    # 自身のテクニックIDと、展開先テクニックとして選択済みのテクニックIDは候補から除外
    # TODO: @children.pluckが2回登場しているので、処理をまとめることができそう
    exclude_ids = [ @technique.id ] + @children.pluck(:technique_id)
    @candidate_techniques = current_user.techniques.where.not(id: exclude_ids)

    @selected_ids = @children.pluck(:technique_id)
    @grouped =
      (@candidate_techniques + @children.map(&:technique))
        .group_by { |t| t.category ? t.category.humanize : "未分類" }
        .transform_values { |arr| arr.map { |t| [ t.name_ja, t.id ] } }
  end

  def update
    @node = current_user.nodes.find(params[:id])
    chart = @node.chart
    # technique = @node.technique

    children = Array(update_params[:children])

    new_names = []
    existing_ids = []

    ActiveRecord::Base.transaction do
      children.each do |child|
        if child.to_s.start_with?("new: ")
          new_names << child.sub(/^new: /, "")
        else
          existing_ids << child.to_i
        end
      end

      new_ids = new_names.map do |name|
        current_user.techniques.find_or_create_by!(name_ja: name, name_en: name).id
      end

      selected_ids = existing_ids + new_ids
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
    end

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
    params.fetch(:node, {}).permit(roots: [])
  end

  def update_params
    # 展開先テクニックに何も選択されていない状態で更新をかけるとparams[:node]自体が送られないので、空配列も許容する。
    params.fetch(:node, {}).permit(children: [])
  end
end
