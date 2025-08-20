class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!, if: :user_signed_in?
  before_action :set_chart

  private

  # ヘッダーにある Flow Chartリンクのために @chart を取得。
  # TODO: 将来的に、Flow Chartリンク先がチャート一覧になったらこの処理は削除して良い。
  # user_signed_in? はインスタンスメソッドとしてしか利用できない(クラス直下で使用できなかった)。
  def set_chart
    @chart = current_user.charts.first
  end

  def after_sign_in_path_for(resource)
    mypage_root_path
  end
end
