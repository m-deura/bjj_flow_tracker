module LoginMacros
  def omniauth_login
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]

    visit root_path

    # ログイン後、ユーザー数が1増加することを確認
    expect {
      click_on I18n.t("shared.login_with", provider: I18n.t("shared.providers.google")), match: :first
      flash_message = I18n.t("devise.omniauth_callbacks.success", kind: I18n.t("shared.providers.google"))
      expect(page).to have_content(/#{Regexp.escape(flash_message)}/i)
    }.to change(User, :count).by(1)

    # ログイン後、ダッシュボード画面に遷移することを確認
    expect(page).to have_current_path(mypage_root_path(locale: I18n.locale))

    # presetsがユーザー所有のテクニック・ノード・チャートにコピーされていることを確認
    tp_count = TechniquePreset.count
    np_count = NodePreset.count

    new_user = User.find_by!(email: "tester1@example.com")
    expect(new_user.techniques.count).to eq(tp_count)
    expect(new_user.nodes.count).to eq(np_count)
    expect(new_user.charts.count).to eq(1)
  end
end
