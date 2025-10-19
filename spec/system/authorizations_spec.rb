require 'rails_helper'

RSpec.describe "Authorizations", type: :system do
  before do
    omniauth_login # "tester1@example.com でログイン
  end

  let(:fixed_name) { "test1" }
  let(:another_user) { create(:user) } # 別ユーザーを用意

  # set_name_forメソッドが使いたいので、Factory不使用
  let(:t) do
    another_user.techniques.create! do |t|
      t.set_name_for("test1")
      t.note = "test note!1"
      t.category = "submission"
    end
  end
  let(:c) { create(:chart, user: another_user, name: fixed_name) }
  let(:n) { create(:node, chart: c) }

  # 「自分が所有するリソースが表示されること」は別のシステムテストで確認しているため、本テストには含めない。

  describe "techniques" do
    it "他ユーザーが所有するテクニックが一覧に表示されない" do
      visit mypage_techniques_path(locale: I18n.locale)
      expect(page).not_to have_content(fixed_name)
    end

    it "他ユーザーが所有するテクニックの編集ページを表示できない" do
      visit edit_mypage_technique_path(id: t.id, locale: I18n.locale)
      expect(page.status_code).to eq 404
    end
  end

  describe "charts" do
    it "他ユーザーが所有するチャートが一覧に表示されない" do
      visit mypage_charts_path(locale: I18n.locale)
      expect(page).not_to have_content(fixed_name)
    end
    it "他ユーザーが所有するチャートの描写用JSONを表示できない(APIが返ってこない)" do
      visit api_v1_chart_path(id: c.id, locale: I18n.locale)
      expect(page).not_to have_content(fixed_name)
      expect(page.status_code).to eq 404
    end
    it "他ユーザーが所有するチャート詳細ページを表示できない" do
      visit mypage_chart_path(id: c.id, locale: I18n.locale)
      expect(page).not_to have_content(fixed_name)
      expect(page.status_code).to eq 404
    end
    it "他ユーザーが所有するチャート編集ページを表示できない" do
      visit edit_mypage_chart_path(id: c.id, locale: I18n.locale)
      expect(page).not_to have_content(fixed_name)
      expect(page.status_code).to eq 404
    end
  end

  describe "nodes" do
    it "他ユーザーが所有するチャートのノード作成ページを表示できない" do
      visit new_mypage_chart_node_path(chart_id: c.id, locale: I18n.locale)
      expect(page).not_to have_content(fixed_name)
      expect(page.status_code).to eq 404
    end

    it "他ユーザーが所有するノード編集ページを表示できない" do
      visit edit_mypage_node_path(id: n.id, locale: I18n.locale)
      expect(page).not_to have_content(fixed_name)
      expect(page.status_code).to eq 404
    end
  end
end
