class Mypage::TechniquesController < ApplicationController
  def index
    @q = current_user.techniques.ransack(params[:q])
    @techniques = @q.result(distinct: true).order(updated_at: :desc)
  end

  def new
    @technique = current_user.techniques.build
  end

  def create
    @technique = current_user.techniques.build

    # まず name 以外を通常更新）
    @technique.assign_attributes(technique_params.except(:name))

    # ロケールに応じた列だけを set_name_for で更新
    @technique.set_name_for(technique_params[:name], I18n.locale)

    if @technique.save
      redirect_to mypage_techniques_path, notice: t("defaults.flash_messages.created", item: Technique.model_name.human)
    else
      flash.now[:alert] = t("defaults.flash_messages.not_created", item: Technique.model_name.human)
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

    # まず name 以外を通常更新）
    @technique.assign_attributes(technique_params.except(:name))

    # ロケールに応じた列だけを set_name_for で更新
    @technique.set_name_for(technique_params[:name], I18n.locale)

    if @technique.save
      redirect_to mypage_techniques_path, notice: t("defaults.flash_messages.updated", item: Technique.model_name.human), status: :see_other
    else
      flash[:alert] = t("defaults.flash_messages.not_updated", item: Technique.model_name.human)

      # turbo_frame内で render 'shared/error_message' しても描写されないので、flash[:errors]経由でエラーメッセージ詳細を描写する。
      flash[:errors] = @technique.errors.full_messages
      redirect_to mypage_techniques_path, status: :see_other
    end
  end

  def destroy
    technique = current_user.techniques.find(params[:id])
    technique.destroy!
    redirect_to mypage_techniques_path, notice: t("defaults.flash_messages.deleted", item: Technique.model_name.human)
  end

  private

  def technique_params
    params.require(:technique).permit(:id, :name, :note, :category)
  end
end
