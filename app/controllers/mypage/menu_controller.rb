class Mypage::MenuController < Mypage::BaseController
  def show
    @chart = current_user.charts.first
  end
end
