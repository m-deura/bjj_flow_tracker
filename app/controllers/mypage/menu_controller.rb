class Mypage::MenuController < ApplicationController
  def show
    @chart = current_user.charts.first
  end
end
