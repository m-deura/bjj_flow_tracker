module LoginMacros
  def omniauth_login
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]

    visit root_path

    tp_count = TechniquePreset.count
    np_count = NodePreset.count

    expect {
      click_on "Google でログイン", match: :first
    }.to change(User, :count).by(1)
    expect(page).to have_current_path(mypage_root_path(locale: I18n.locale))

    new_user = User.find_by!(email: "tester1@example.com")
    expect(new_user.techniques.count).to eq(tp_count)
    expect(new_user.nodes.count).to eq(np_count)
    expect(new_user.charts.count).to eq(1)
  end
end
