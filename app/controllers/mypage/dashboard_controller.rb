class Mypage::DashboardController < ApplicationController
  def show
    @technique_count = current_user.techniques.count
    @chart_count = current_user.charts.count
    @node_count = current_user.charts.joins(:nodes).count
  end
end
