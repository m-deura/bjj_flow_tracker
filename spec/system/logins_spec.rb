require 'rails_helper'

RSpec.describe "Logins", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "テスト" do
    it "ログイン" do
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]

      visit root_path
      click_on "Google でログイン", match: :first
      expect(page).to have_current_path(mypage_root_path)
    end
  end

  pending "add some scenarios (or delete) #{__FILE__}"
end
