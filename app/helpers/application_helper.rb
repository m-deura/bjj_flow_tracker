module ApplicationHelper
  def base_title
    "BJJ Flow Tracker"
  end

  def og_locale_for(loc = I18n.locale)
    { ja: "ja_JP", en: "en_US" }[loc.to_sym] || "ja_JP"
  end

  def meta_description_for(loc = I18n.locale)
    case loc.to_sym
    when :en
      "With #{base_title}, organize your BJJ training and visualize match/sparring flows."
    else
      "#{base_title} は、ブラジリアン柔術の練習記録を整理し、試合やスパーの展開を可視化できるツールです。"
    end
  end

  def default_meta_tags
    {
      site: base_title,
      # title: はここで定義せず、application.html.erb上で指定。
      reverse: true, # 「site | title」ではなく「title | site」の表記になる。
      charset: "utf-8",
      description: meta_description_for,
      canonical: url_for(locale: I18n.locale, only_path: false),
      separator: "|",
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: "website",
        url: :canonical,
        image: image_url("ogp.png"),
        locale: og_locale_for,
        locale_alternate: I18n.available_locales
          .reject { |l| l == I18n.locale }
          .map { |l| og_locale_for(l) }
        },
      twitter: {
        card: "summary_large_image",
        site: "@yakiRUNTEQ67a",
        image: image_url("ogp.png")
      }
    }
  end
end
