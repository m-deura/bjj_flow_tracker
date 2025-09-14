class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!
  before_action :set_chart, if: :user_signed_in?
  around_action :switch_locale
  before_action :store_locale_in_session

  private

  # ヘッダーにある Flow Chartリンクのために @chart を取得。
  # TODO: 将来的に、Flow Chartリンク先がチャート一覧になったらこの処理は削除して良い。
  # user_signed_in? はインスタンスメソッドとしてしか利用できない(クラス直下で使用できなかった)。
  def set_chart
    return unless user_signed_in?
    @chart = current_user.charts.first
  end

  def after_sign_in_path_for(resource)
    mypage_root_path
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def switch_locale(&action)
    I18n.with_locale(resolve_locale, &action)
  end

  def resolve_locale
    # ロケール設定。上にあるほど優先順位が高い。
    # URL
    locale = params[:locale]&.to_sym
    return locale if locale.in?(I18n.available_locales.map(&:to_sym))

    # セッション
    locale = session[:locale]&.to_sym
    return locale if locale.in?(I18n.available_locales.map(&:to_sym))

    # デフォルトのロケール(ja)
    I18n.default_locale
  end

  def store_locale_in_session
    session[:locale] = I18n.locale
  end
end
