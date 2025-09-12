module ApplicationHelper
  def base_title
    "BJJ Flow Tracker"
  end

  def default_meta_tags
    {
      site: base_title,
      # title: はここで定義せず、application.html.erb上で指定。
      reverse: true, # 「site | title」ではなく「title | site」の表記になる。
      charset: "utf-8",
      description: "#{base_title} では、ブラジリアン柔術の練習記録を整理し、試合やスパーの展開を可視化することができます。",
      canonical: request.base_url + request.path,
      separator: "|",
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: "website",
        url: :canonical,
        image: image_url("ogp.png"),
        locale: "ja_JP",
        locale_alternate: "en_US"
      },
      twitter: {
        card: "summary_large_image",
        site: "@yakiRUNTEQ67a",
        image: image_url("ogp.png")
      }
    }
  end
end
