require 'rails_helper'

RSpec.describe "Techniques", type: :system do
  before do
    omniauth_login
  end

  let(:user) { User.find_by(email: "tester1@example.com") }

  # pending "add some scenarios (or delete) #{__FILE__}"

  describe "indexアクション" do
    it "ダッシュボードからテクニック画面に遷移できる" do
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
        visit mypage_techniques_path
        expect(page).to have_content("test1")
      end
    end
  end

  describe "showアクション" do
  end

  describe "newアクション" do
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
