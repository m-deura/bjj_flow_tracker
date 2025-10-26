module TourMacros
  # i18n_scope: 例 [I18n.locale.to_s, "guides", "node"]
  # start_selector: 例 '[data-action~="click->step-guide#startNodeGuide"]'
  def count_steps(
    locale_file: Rails.root.join("config/locales/guides/#{I18n.locale}.yml"),
    i18n_scope:,
    start_selector:,
    wait: 15
  )
    # 1) ツアー開始
    find(start_selector).click

    # 2) 最初のツールチップが出るのを待つ
    expect(page).to have_css('.introjs-tooltip', wait: wait)

    # 3) ロケールファイルから期待ステップ数を取得
    yaml = YAML.safe_load(File.read(locale_file))
    steps = yaml.dig(*i18n_scope)&.keys&.grep(/\Astep\d+\z/)
    expected_count = steps.size

    # 4) 期待回数だけ「ある方のボタン」を見つけてクリック
    clicks = 0
    loop do
      # Nextボタンが存在し、かつ有効か確認
      has_next = page.has_css?('.introjs-nextbutton')
      break unless has_next

      # Nextボタン(最終ステップガイドの"Done"ボタンを含む)をクリック
      find('.introjs-nextbutton').click

      clicks += 1
    end

    expect(clicks).to eq(expected_count)
  end
end
