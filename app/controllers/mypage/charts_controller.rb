class Mypage::ChartsController < ApplicationController
  def show
  end

  def edit
    @chart = current_user.charts.first
  end

  def update
  end
end
