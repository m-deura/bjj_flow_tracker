class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!
  around_action :switch_locale
  before_action :store_locale_in_session

  private

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
