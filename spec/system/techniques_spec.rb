require 'rails_helper'

RSpec.describe "Techniques", type: :system do
  before do
    omniauth_login
  end

  let(:user) { User.find_by(email: "tester1@example.com") }

  # pending "add some scenarios (or delete) #{__FILE__}"

  describe "indexアクション" do
    it "ダッシュボードにあるテクニック画面へのリンクが機能する" do
      click_on "Technique", match: :first
      expect(page).to have_current_path(mypage_techniques_path(locale: I18n.locale))
    end

    it "プリセットのテクニックが確認できる" do
      visit mypage_techniques_path(locale: I18n.locale)
      expect(page).to have_content("マウント")
    end

    context "登録されたテクニックがない(プリセットを含めテクニックを全削除した)場合" do
      before do
        Edge.destroy_all
        user.charts.find_each do |chart|
          # chart.edges.delete_all #まだリレーションを作成していないためコメントアウト
          chart.nodes.delete_all
        end
        user.techniques.delete_all
      end

      it "表示するテクニックがない旨が表示される" do
        visit mypage_techniques_path(locale: I18n.locale)
        expect(page).to have_content(I18n.t("mypage.techniques.index.nothing_here"))
      end
    end

    it "新規作成ページへのリンクが機能する" do
      visit mypage_techniques_path(locale: I18n.locale)
      click_link(I18n.t("defaults.create"))
      expect(page).to have_current_path(new_mypage_technique_path(locale: I18n.locale))
    end
  end

  describe "newアクション" do
    it "新規作成フォームが表示される" do
      visit new_mypage_technique_path(locale: I18n.locale)
      expect(page).to have_field(I18n.t("helpers.label.technique_name"))
      expect(page).to have_field(I18n.t("helpers.label.note"))
      expect(page).to have_field(I18n.t("helpers.label.category"))
      expect(page).to have_button(I18n.t("helpers.submit.create"))
    end

    it "一覧ページへ戻るリンクが機能する" do
      visit new_mypage_technique_path(locale: I18n.locale)
      click_link(I18n.t("defaults.back"))
      expect(page).to have_current_path(mypage_techniques_path(locale: I18n.locale))
    end
  end

  describe "editアクション" do
    let!(:technique) do
      user.techniques.create! do |t|
        t.set_name_for("test1")
      end
    end

    it "編集フォームが表示される", :js do
      visit mypage_techniques_path(locale: I18n.locale)
      expect(page).to have_css('a[data-turbo-frame="technique-drawer"]')
      find('a[data-turbo-frame="technique-drawer"]', match: :first).click
      expect(page).to have_field(I18n.t("helpers.label.technique_name"), with: "test1")
      expect(page).to have_field(I18n.t("helpers.label.note"))
      expect(page).to have_field(I18n.t("helpers.label.category"))
      expect(page).to have_button(I18n.t("helpers.submit.update"))
      expect(page).to have_link(I18n.t("defaults.delete"))
    end
  end

  describe "createアクション" do
  end

  describe "updateアクション" do
  end

  describe "destroyアクション" do
  end
end
