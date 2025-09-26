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

    context "登録されたテクニックがない場合" do
      it "表示するテクニックがない旨が表示される" do
        visit mypage_techniques_path
        expect(page).to have_content(I18n.t("mypage.techniques.index.nothing_here"))
      end
    end

    context "登録されているテクニックがある場合" do
      let!(:technique) do
        user.techniques.create! do |t|
          t.set_name_for("test1")
        end
      end

      it "プリセットのテクニックが確認できる" do
        visit mypage_techniques_path(locale: I18n.locale)
        expect(page).to have_content("test1")
      end
    end

    it "新規作成ページへのリンクが機能する" do
      visit mypage_techniques_path
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
  end

  describe "createアクション" do
  end

  describe "updateアクション" do
  end

  describe "destroyアクション" do
  end
end
