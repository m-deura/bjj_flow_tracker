module LoginMacros
  def omniauth_login
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]

    visit root_path
    click_on "Google でログイン", match: :first
    expect(page).to have_current_path(mypage_root_path(locale: I18n.locale))
  end
end
