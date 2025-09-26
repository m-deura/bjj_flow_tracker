require 'rails_helper'

RSpec.describe "Logins", type: :system do
  describe "ログイン・ログアウト" do
    it "ログインできる" do
      omniauth_login
    end

    it "ログアウトできる" do
      omniauth_login
      visit mypage_root_path
      # save_and_open_page
      click_on "ログアウト", match: :first

      expect(page).to have_current_path(root_path(I18n.locale))
      expect(page).to have_content("ログアウトしました。")
    end
  end

    context "未ログインの場合" do
      it "マイページにアクセスできない" do
        visit mypage_root_path

        expect(page).to have_current_path(root_path(locale: I18n.locale))
        expect(page).to have_content("ログインしてください。")
      end
    end
  end

# pending "add some scenarios (or delete) #{__FILE__}"
