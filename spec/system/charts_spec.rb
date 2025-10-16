require 'rails_helper'

RSpec.describe "Charts", type: :system do
  before do
    omniauth_login
  end

  let(:user) { User.find_by(email: "tester1@example.com") }
  let(:cp_id) { user.charts.where("name LIKE ?", "%preset%").first.id }

  describe "indexアクション" do
    it "ダッシュボードにあるFlow Chart画面へのリンクが機能する" do
      click_on "Flow Chart", match: :first
      expect(page).to have_current_path(mypage_charts_path(locale: I18n.locale))
    end

    it "プリセットのチャートが確認できる" do
      visit mypage_charts_path(locale: I18n.locale)
      expect(page).to have_content(/preset_\d{8}-\d{6}/)
    end

    context "登録されたチャートがない(プリセットを含めチャートを全削除した)場合" do
      before do
        user.charts.destroy_all
      end

      it "表示するチャートがない旨が表示される" do
        visit mypage_charts_path(locale: I18n.locale)
        expect(page).to have_content(I18n.t("mypage.charts.index.nothing_here"))
      end
    end

    it "新規作成ページへのリンクが機能する" do
      visit mypage_charts_path(locale: I18n.locale)
      click_link(I18n.t("defaults.create"))
      expect(page).to have_current_path(new_mypage_chart_path(locale: I18n.locale))
    end

    it "詳細ページへのリンクが機能する", :js do
      visit mypage_charts_path(locale: I18n.locale)
      find('a[data-turbo-frame="_top"]', match: :first).click
      expect(page).to have_current_path(mypage_chart_path(id: cp_id, locale: I18n.locale))
    end

    context "検索した文字列がヒットする場合" do
      before do
        user.charts.create! do |c|
          c.name = "test1"
        end

        user.charts.create! do |c|
          c.name = "test2"
        end
      end

      it "該当するチャート名のみが一覧に表示される", :js do # inputイベント発火(send_keys利用)のために要js
        visit mypage_charts_path(locale: I18n.locale)
        field = find('input[name="q[name_cont]"]')
        field.send_keys("test1")
        expect(page).to have_content("test1")
        expect(page).not_to have_content("test2")
      end

      it "該当するノートを持つチャートのみが一覧に表示される", :js do
        visit mypage_charts_path(locale: I18n.locale)
        field = find('input[name="q[name_cont]"]')
        field.send_keys("test1")
        expect(page).to have_content("test1")
        expect(page).not_to have_content("test2")
      end
    end

    context "どのチャート名・ノートにも該当しないランダム文字列で検索した場合" do
      it "表示するチャートがない旨が表示される", :js do
        visit mypage_charts_path(locale: I18n.locale)
        field = find('input[name="q[name_cont]"]')
        field.send_keys("Hello, world!!")
        expect(page).to have_content(I18n.t("mypage.charts.index.nothing_here"))
      end
    end
  end

  describe "showアクション" do
    it "一覧ページへ戻るリンクが機能する" do
      visit mypage_chart_path(id: cp_id, locale: I18n.locale)
      click_link(I18n.t("defaults.back"))
      expect(page).to have_current_path(mypage_charts_path(locale: I18n.locale))
    end
  end

  describe "newアクション" do
    it "新規作成フォームが表示される" do
      visit new_mypage_chart_path(locale: I18n.locale)
      expect(page).to have_field(I18n.t("helpers.label.chart_name"))
      expect(page).to have_button(I18n.t("helpers.submit.create"))
    end

    it "一覧ページへ戻るリンクが機能する" do
      visit new_mypage_chart_path(locale: I18n.locale)
      click_link(I18n.t("defaults.back"))
      expect(page).to have_current_path(mypage_charts_path(locale: I18n.locale))
    end
  end
end
