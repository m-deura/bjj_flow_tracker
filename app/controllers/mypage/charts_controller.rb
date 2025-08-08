class Mypage::ChartsController < Mypage::BaseController
  def show
    @chart = current_user.charts.first
  end

  def edit
    @chart = current_user.charts.first
  end

  def update
  end
end
