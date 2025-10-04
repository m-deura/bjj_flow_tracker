class Mypage::DashboardController < ApplicationController
  def show
    @technique_count = current_user.techniques.count
    @node_count = @chart ? @chart.nodes.count : 0
  end
end
