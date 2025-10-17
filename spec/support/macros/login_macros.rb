module LoginMacros
  def omniauth_login
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]

    visit root_path

    # ログイン後、ユーザー数が1増加することを確認
    expect {
      click_on I18n.t("shared.sign_in_with", provider: I18n.t("shared.providers.google")), match: :first
      flash_message = I18n.t("devise.omniauth_callbacks.success", kind: I18n.t("shared.providers.google"))
      # Googleアカウント表記でもgoogleアカウント表記でもOKとするため、正規表現ignoreオプション付加
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

    # トップページに表示されるボタンが意図通りになっているか確認
    visit root_path(locale: I18n.locale)
    expect(page).to have_content(I18n.t("pages.top.hero.already_signed_in"))
    expect(page).to have_content(I18n.t("pages.top.hero.try_as_guest"))
    expect(page).not_to have_content(I18n.t("shared.sign_in_with", provider: I18n.t("shared.providers.google")))
    expect(page).not_to have_content(I18n.t("pages.top.hero.signed_in_as_guest"))

    # 本来のログイン直後の遷移先に戻る
    visit mypage_root_path(locale: I18n.locale)
  end

  def guest_login
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]

    visit root_path

    # ログイン後、ユーザー数が1増加することを確認
    expect {
      click_on I18n.t("pages.top.hero.try_as_guest"), match: :first
      expect(page).to have_content(I18n.t("defaults.flash_messages.guest_signed_in"))
      expect(page).to have_content(I18n.t("defaults.flash_messages.guest_notice"))
    }.to change(User, :count).by(1)

    # ログイン後、ダッシュボード画面に遷移することを確認
    expect(page).to have_current_path(mypage_root_path(locale: I18n.locale))

    # presetsがユーザー所有のテクニック・ノード・チャートにコピーされていることを確認
    tp_count = TechniquePreset.count
    np_count = NodePreset.count

    new_user = User.find_by!(provider: "guest")
    expect(new_user.techniques.count).to eq(tp_count)
    expect(new_user.nodes.count).to eq(np_count)
    expect(new_user.charts.count).to eq(1)

    # トップページに表示されるボタンが意図通りになっているか確認
    visit root_path
    expect(page).not_to have_content(I18n.t("pages.top.hero.already_signed_in"))
    expect(page).not_to have_content(I18n.t("pages.top.hero.try_as_guest"))
    expect(page).to have_content(I18n.t("shared.sign_in_with", provider: I18n.t("shared.providers.google")))
    expect(page).to have_content(I18n.t("pages.top.hero.signed_in_as_guest"))

    # 本来のログイン直後の遷移先に戻る
    visit mypage_root_path(locale: I18n.locale)
  end
end
