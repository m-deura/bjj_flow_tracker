class Mypage::ChartsController < ApplicationController
  def show
    @chart = current_user.charts.first
  end

  def edit
    @chart = current_user.charts.first
  end

  def update
  end
end
