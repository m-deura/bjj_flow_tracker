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
    count_steps(
      i18n_scope: [ "#{I18n.locale}", "guides", "dashboard" ],
      start_selector: '[data-action~="click->step-guide#startDashboardGuide"]',
    )
  end
end
