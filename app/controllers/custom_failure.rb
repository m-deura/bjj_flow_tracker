class CustomFailure < Devise::FailureApp
  def respond
    I18n.locale = resolve_locale_from_request  # ミドルウェアレベルでロケール決定
    super
  end

  private

  # ログインしていない状態で要ログインページにアクセスした際のリダイレクト先指定
  def redirect_url
    root_path(locale: I18n.locale)
  end

  def resolve_locale_from_request
    avail = I18n.available_locales.map(&:to_s)

    # /:locale/... をパスから検出
    if m = request.path.match(%r{\A/(#{avail.join('|')})(?:/|$)})
      return m[1].to_sym
    end

    # セッション
    if loc = request.session["locale"]
      return loc.to_sym if avail.include?(loc.to_s)
    end

    I18n.default_locale
  end
end
