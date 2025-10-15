require 'rails_helper'

RSpec.describe "Logins", type: :system do
  describe "ログイン・ログアウト" do
    context "Googleアカウントを使った場合" do
      it "ログインできる" do
        omniauth_login
      end

      it "ログアウトできる" do
        omniauth_login
        # save_and_open_page
        # PC用とモバイル用でログアウトボタンが2つ見えている判定になるので、match: :first
        click_on I18n.t("header.sign_out"), match: :first

        expect(page).to have_current_path(root_path(I18n.locale))
        expect(page).to have_content(I18n.t("devise.sessions.signed_out"))
      end
    end

    context "ゲストユーザーの場合" do
      it "ログインできる" do
        guest_login
      end

      it "ログアウトできる" do
        guest_login
        # save_and_open_page
        # PC用とモバイル用でログアウトボタンが2つ見えている判定になるので、match: :first
        click_on I18n.t("header.sign_out"), match: :first

        expect(page).to have_current_path(root_path(I18n.locale))
        expect(page).to have_content(I18n.t("devise.sessions.signed_out"))
      end
    end

    context "未ログインの場合" do
      it "マイページにアクセスできない" do
        visit mypage_root_path

        expect(page).to have_current_path(root_path(locale: I18n.locale))
        expect(page).to have_content(I18n.t("devise.failure.unauthenticated"))
      end
    end
  end
end
