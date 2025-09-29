require 'rails_helper'

RSpec.describe "Locales", type: :system do
  before do
    omniauth_login
    user = User.find_by(email: "tester1@example.com")
    @chart = user.charts.first

    # 本テストで使うプリセットからコピーされたテクニック/ノードの存在を確認
    preset_technique = user.techniques.find_by!(name_ja: "トップポジション")
    @chart.nodes.find_by!(technique_id: preset_technique.id)

    # ユーザー作成のテクニック/ノード
    @user_technique = user.techniques.create! do |t|
      t.set_name_for("テスト1")
    end
    @user_node = @chart.nodes.create!(technique_id: @user_technique.id)
  end

  describe "Technqueメニュー" do
    context "プリセットからコピーされたテクニックの場合" do
      it "ロケール切り替えに伴ってテクニック名が変わる" do
        # jaの場合
        visit mypage_techniques_path(locale: I18n.locale)
        switch_locale(to: :ja)
        expect(page).to have_content("トップポジション")
        expect(page).not_to have_content("Top Position")

        # enの場合
        switch_locale(to: :en)
        expect(page).not_to have_content("トップポジション")
        expect(page).to have_content("Top Position")
      end
    end

    context "ユーザー作成のテクニックの場合" do
      it "ロケールを切り替えてもテクニック名は変わらない" do
        visit mypage_techniques_path(locale: I18n.locale)
        switch_locale(to: :ja)
        expect(page).to have_content("テスト1")

        switch_locale(to: :en)
        expect(page).to have_content("テスト1")
      end
    end
  end

  describe "Flow Chartメニュー" do
    context "プリセットからコピーされたテクニックの場合" do
      it "ロケール切り替えに伴ってテクニック名が変わる" do
        # api_v1_chart_pathにはロケール切り替えプルダウンがないため、一旦チャート画面でロケール切り替え
        visit mypage_chart_path(id: @chart.id, locale: I18n.locale)
        switch_locale(to: :ja)
        visit api_v1_chart_path(id: @chart.id)
        expect(page).to have_content("トップポジション")
        expect(page).not_to have_content("Top Position")

        visit mypage_chart_path(id: @chart.id, locale: I18n.locale)
        switch_locale(to: :en)
        # RSpecプロセスのロケールは:jaで変わらないので、ここでロケールは渡さない
        visit api_v1_chart_path(id: @chart)
        expect(page).not_to have_content("トップポジション")
        expect(page).to have_content("Top Position")
      end
    end

    context "ユーザー作成のテクニックの場合" do
      it "ロケールを切り替えてもテクニック名は変わらない" do
        visit mypage_chart_path(id: @chart.id, locale: I18n.locale)
        switch_locale(to: :ja)
        visit api_v1_chart_path(id: @chart.id)
        expect(page).to have_content("テスト1")

        visit mypage_chart_path(id: @chart.id, locale: I18n.locale)
        switch_locale(to: :en)
        visit api_v1_chart_path(id: @chart.id)
        expect(page).to have_content("テスト1")
      end
    end
  end
end
