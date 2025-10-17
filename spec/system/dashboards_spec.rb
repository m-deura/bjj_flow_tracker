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
end
