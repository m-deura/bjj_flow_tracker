class Mypage::ChartsController < ApplicationController
  def index
    @q = current_user.charts.ransack(params[:q])
    @charts = @q.result(distinct: true).order(updated_at: :desc)
  end

  def new
    @chart = current_user.charts.build
  end

  def create
    @chart = current_user.charts.build(chart_params)

    if @chart.save
      redirect_to mypage_charts_path, notice: t("defaults.flash_messages.created", item: Chart.model_name.human)
    else
      flash.now[:alert] = t("defaults.flash_messages.not_created", item: Chart.model_name.human)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @chart = current_user.charts.find(params[:id])
  end

  def edit
    @chart = current_user.charts.find(params[:id])
    render turbo_stream: turbo_stream.replace(
      "chart-title",
      partial: "title_form",
      locals: { chart: @chart }
    )
  end

  def update
    @chart = current_user.charts.find(params[:id])

    if @chart.update(chart_params)
      redirect_to mypage_chart_path(id: @chart.id), notice: t("defaults.flash_messages.updated", item: Chart.model_name.human), status: :see_other
    else
      flash[:alert] = t("defaults.flash_messages.not_updated", item: Chart.model_name.human)

      # turbo_frame内で render 'shared/error_message' しても描写されないので、flash[:errors]経由でエラーメッセージ詳細を描写する。
      flash[:errors] = @chart.errors.full_messages
      redirect_to mypage_chart_path(id: @chart.id), status: :see_other
    end
  end

  def destroy
    chart = current_user.charts.find(params[:id])
    chart.destroy!
    redirect_to mypage_charts_path, notice: t("defaults.flash_messages.deleted", item: Chart.model_name.human)
  end

  private

  def chart_params
    params.require(:chart).permit(:name)
  end
end
