class Mypage::TechniquesController < ApplicationController
  def index
    @q = current_user.techniques.ransack(params[:q])
    @techniques = @q.result(distinct: true).order(updated_at: :desc)


    # ステップガイドに含まれるChartメニューへのアクセスリンクのため
    @chart = current_user.charts.first
  end

  def new
    @technique = current_user.techniques.build
  end

  def create
    @technique = current_user.techniques.build(technique_params)
    if @technique.save
      redirect_to mypage_techniques_path, notice: "保存しました"
    else
      flash.now[:alert] = "保存できませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @technique = Technique.find(params[:id])
  end

  def edit
    @technique = current_user.techniques.find(params[:id])
  end

  def update
    @technique = current_user.techniques.find(params[:id])

    if @technique.update(technique_params)
      # チャート画面上からテクニックを更新した場合、chart_idがparamsに含まれる。
      redirect_to mypage_techniques_path, notice: "保存しました", status: :see_other
    else
      flash[:alert] = "保存できませんでした"

      # turbo_frame内で render 'shared/error_message' しても描写されないので、flash[:errors]経由でエラーメッセージ詳細を描写する。
      flash[:errors] = @technique.errors.full_messages
      redirect_to location, status: :see_other
    end
  end

  def destroy
    technique = Technique.find(params[:id])
    technique.destroy!
    redirect_to mypage_techniques_path, notice: "削除しました"
  end

  private

  def technique_params
    params.require(:technique).permit(:id, :name_ja, :note, :category)
  end
end
