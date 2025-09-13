module LocaleHelper
  def switch_locale_path(to_locale)
    # 現在のパスの先頭セグメントを置換。query string も維持
    segments = request.path.split("/")
    if I18n.available_locales.map(&:to_s).include?(segments.second)
      segments[1] = to_locale.to_s
    else
      segments.insert(1, to_locale.to_s)
    end
    path = segments.join("/")
    request.query_string.present? ? "#{path}?#{request.query_string}" : path
  end
end
