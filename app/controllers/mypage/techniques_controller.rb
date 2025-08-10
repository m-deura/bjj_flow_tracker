class Mypage::TechniquesController < Mypage::BaseController
  def index
    @techniques = current_user.techniques
  end

  def new
    @technique = current_user.techniques.build
    @technique.outgoing_transitions.build if @technique.outgoing_transitions.blank?
  end

  def create
    @technique = current_user.techniques.build(technique_params)
    if @technique.save
      redirect_to edit_mypage_technique_path(@technique), notice: "保存しました"
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
    @technique.outgoing_transitions.build if @technique.outgoing_transitions.blank?
    @techniques = current_user.techniques.where.not(id: @technique.id)
  end

  def update
    @technique = current_user.techniques.find(params[:id])
    @techniques = current_user.techniques.where.not(id: @technique.id)

    if @technique.update(technique_params)
      # チャート画面上からテクニックを更新した場合、chart_idがparamsに含まれる。
      chart = current_user.charts.find_by(id: params[:chart_id])
      location = chart ? mypage_chart_path(chart) : mypage_techniques_path
      redirect_to location, notice: "保存しました"
    else
      flash.now[:alert] = "保存できませんでした"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    technique = Technique.find(params[:id])
    technique.destroy!
    redirect_to mypage_techniques_path, notice: "削除しました"
  end

  private

  def technique_params
    params.require(:technique).permit(:id, :name, :note, :category, outgoing_transitions_attributes: [ :id, :to_technique_id, :trigger, :_destroy ])
  end
end
