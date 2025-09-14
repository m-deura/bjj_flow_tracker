class Mypage::NodesController < ApplicationController
  def new
    @chart = current_user.charts.find(params[:chart_id])
    exclude_ids = @chart.nodes.roots.pluck(:technique_id)
    @candidate_techniques = current_user.techniques.where.not(id: exclude_ids)

    @grouped = @candidate_techniques
        .group_by { |tech| tech.category ? tech.category.humanize : t("enums.category.nil") }
        .transform_values { |arr| arr.map { |tech| [ tech.name_for, tech.id ] } }

    render :new, formats: :turbo_stream
  end

  def create
    @chart = current_user.charts.find(params[:chart_id])

    begin
      ActiveRecord::Base.transaction do
        roots = Array(create_params[:roots])
        raise ArgumentError, t("defaults.flash_messages.multiple_select", item: t("terms.root_nodes")) if roots.empty?

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

      redirect_to mypage_chart_path(@chart), notice: t("defaults.flash_messages.created", item: t("terms.root_nodes"))

    rescue ArgumentError => e
      flash[:alert] = e.message
      redirect_to mypage_chart_path(@chart)
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = e.message
      redirect_to mypage_chart_path(@chart)
    rescue StandardError => e
      flash[:alert] = t("defaults.flash_messages.not_created", item: t("terms.root_nodes"))
      redirect_to mypage_chart_path(@chart)
    end
  end

  def edit
    @node = current_user.nodes.find(params[:id])
    @chart = @node.chart
    @technique = @node.technique

    @form = NodeEditForm.new(node: @node, current_user: current_user)

    # 自身のテクニックIDと、展開先テクニックとして選択済みのテクニックIDは候補から除外
    children_ids = @node.children.pluck(:technique_id)
    exclude_ids = [ @technique.id ] + children_ids
    @candidate_techniques = current_user.techniques.where.not(id: exclude_ids)

    # grouped_options_for_select 用
    @selected_ids = children_ids.map!(&:to_s)
    @grouped =
      (@candidate_techniques + @node.children.includes(:technique).map(&:technique))
        .group_by { |tech| tech.category ? tech.category.humanize : t("enums.category.nil") }
        .transform_values { |arr| arr.map { |tech| [ tech.name_for, tech.id ] } }

    render :edit, formats: :turbo_stream
  end

  def update
    @node = current_user.nodes.find(params[:id])
    chart = @node.chart
    @form = NodeEditForm.new(
      node: @node,
      current_user: current_user,
      **node_edit_form_params.to_h.symbolize_keys
      # Strong Parameterをハッシュに変換後、シンボルに変換(キーワード引数はシンボルである必要がある)。その後、** を使ってキーワード引数として展開。
    )

    chart = @node.chart

    if @form.save
      redirect_to mypage_chart_path(chart), notice: t("defaults.flash_messages.updated", item: Node.model_name.human), status: :see_other
    else
      flash[:alert] = t("defaults.flash_messages.not_updated", item: Node.model_name.human)
      flash[:errors] = @form.errors.full_messages
      # status: :unprocessable_entity(422) だと フルページ更新できない
      redirect_to mypage_chart_path(chart), status: :see_other
    end
  end

  def destroy
    node = current_user.nodes.find(params[:id])
    chart = node.chart
    node.destroy!
    redirect_to mypage_chart_path(chart), notice: t("defaults.flash_messages.deleted", item: Node.model_name.human), status: :see_other
  end

  private

  def create_params
    # 展開先テクニックに何も選択されていない状態で更新をかけるとparams[:node]自体が送られないので、空配列も許容する。
    params.fetch(:node, {}).permit(roots: [])
  end

  def node_edit_form_params
    # children が空でも配列を許容
    params.require(:node_edit_form).permit(:name_ja, :note, :category, children: [])
  end
end
