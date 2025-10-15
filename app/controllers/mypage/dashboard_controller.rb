class Mypage::DashboardController < ApplicationController
  def show
    @techniques_count = current_user.techniques.count
    @charts_count = current_user.charts.count
    # @nodes_count = current_user.charts.joins(:nodes).count
  end
end
