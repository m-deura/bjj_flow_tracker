require 'rails_helper'

RSpec.describe "Logins", type: :system do
  before do
    driven_by(:rack_test)
  end

<<<<<<< Updated upstream
  describe "テスト" do
=======
  describe "ログイン・ログアウト" do
>>>>>>> Stashed changes
    it "ログインできる" do
      omniauth_login
    end

    it "ログアウトできる" do
      omniauth_login
      visit mypage_root_path
      # save_and_open_page
      click_on "ログアウト"

      expect(page).to have_current_path(root_path)
      expect(page).to have_content("ログアウトしました。")
    end
<<<<<<< Updated upstream
  end

  pending "add some scenarios (or delete) #{__FILE__}"
=======

    context "未ログインの場合" do
      it "マイページにアクセスできない" do
        visit mypage_root_path

        expect(page).to have_current_path(root_path)
        expect(page).to have_content("ログインしてください。")
      end
    end
  end

  # pending "add some scenarios (or delete) #{__FILE__}"
>>>>>>> Stashed changes
end
