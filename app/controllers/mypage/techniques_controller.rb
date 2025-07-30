class Mypage::TechniquesController < Mypage::BaseController
  def index
    @techniques = current_user.techniques
  end

  def new
    @technique = current_user.techniques.build
    @technique.outgoing_transitions.build if @technique.outgoing_transitions.blank?
    @existing_techniques = current_user.techniques.select(:id, :name)
  end

  def create
    @technique = current_user.techniques.build(technique_params)
    if @technique.save
      redirect_to edit_mypage_technique_path(@technique), success: "保存しました"
    else
      flash.now[:danger] = "保存できませんでした"
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
    binding.pry
    @technique = current_user.techniques.find(params[:id])
    @techniques = current_user.techniques.where.not(id: @technique.id)

    if @technique.update(technique_params)
      redirect_to mypage_techniques_path, success: "保存しました"
    else
      flash.now[:danger] = "保存できませんでした"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    technique = Technique.find(params[:id])
    technique.destroy
    redirect_to mypage_techniques_path, success: "削除しました"
  end

  private

  def technique_params
    params.require(:technique).permit(:id, :name, :note, :category, outgoing_transitions_attributes: [ :id, :to_technique_id, :trigger, :_destroy ])
  end
end
