require 'rails_helper'

RSpec.describe "Dashboards", type: :system do
  before do
    omniauth_login
  end

  it "テクニック一覧画面へのリンクが機能する" do
    click_on "Technique", match: :first
    expect(page).to have_current_path(mypage_techniques_path(locale: I18n.locale))
  end

  it "チャート一覧画面へのリンクが機能する" do
    click_on "Flow Chart", match: :first
    expect(page).to have_current_path(mypage_charts_path(locale: I18n.locale))
  end

  it "ステップガイドが開始できる", :js do
    # ログイン後、ダッシュボードに遷移する前提
    find(:css, '[data-action~="click->step-guide#startDashboardGuide"]').click
    expect(page).to have_css('.introjs-tour')
  end

  # ロケールファイル間のi18nキー非対称性は、CIで実行される i18n-tasks health によって検知されるのでテストは行わない。
  it "ロケールファイルに書いたガイド数と実際のガイド数が一致する", :js do
    # ガイド開始
    find(:css, '[data-action~="click->step-guide#startDashboardGuide"]').click

    # Next or Doneボタンのクリック数をカウント
    clicks = 0

    loop do
      # Nextボタンが存在し、かつ有効か確認
      has_next = page.has_css?('.introjs-nextbutton')
      break unless has_next

      # 最終ステップガイドの"Done"ボタンを含む
      expect(page).to have_css('.introjs-nextbutton')
      next_btn = find('.introjs-nextbutton')

      # Next or Done ボタンをクリック
      next_btn.click
      clicks += 1
    end

    # ロケールファイルからガイド用のI18nキーを取り出してカウント
    path = Rails.root.join("config/locales/guides/#{I18n.locale}.yml")
    hash = YAML.safe_load(File.read(path))
    steps = hash.dig("#{I18n.locale}", "guides", "dashboard").keys.grep(/\Astep\d+\z/)

    expect(steps.size).to eq clicks
  end
end
