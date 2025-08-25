module LoginMacros
  def login(user)
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]

    visit root_path
    click_on "Google でログイン"
    expect(page).to have_current_path(mypage_root_path)
  end
end
