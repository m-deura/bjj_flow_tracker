require 'rails_helper'

RSpec.describe "Charts", type: :system do
  before do
    omniauth_login
  end

  let(:user) { User.find_by(email: "tester1@example.com") }
  let(:cp_id) { user.charts.where("name LIKE ?", "%preset%").first.id }

  describe "indexアクション" do
    it "ダッシュボードにあるFlow Chart画面へのリンクが機能する" do
      click_on "Flow Chart", match: :first
      expect(page).to have_current_path(mypage_charts_path(locale: I18n.locale))
    end

    it "プリセットのチャートが確認できる" do
      visit mypage_charts_path(locale: I18n.locale)
      expect(page).to have_content(/preset_\d{8}-\d{6}/)
    end

    context "登録されたチャートがない(プリセットを含めチャートを全削除した)場合" do
      before do
        user.charts.destroy_all
      end

      it "表示するチャートがない旨が表示される" do
        visit mypage_charts_path(locale: I18n.locale)
        expect(page).to have_content(I18n.t("mypage.charts.index.nothing_here"))
      end
    end

    it "新規作成ページへのリンクが機能する" do
      visit mypage_charts_path(locale: I18n.locale)
      click_link(I18n.t("defaults.create"))
      expect(page).to have_current_path(new_mypage_chart_path(locale: I18n.locale))
    end

    it "詳細ページへのリンクが機能する", :js do
      visit mypage_charts_path(locale: I18n.locale)
      find('a[data-turbo-frame="_top"]', match: :first).click
      expect(page).to have_current_path(mypage_chart_path(id: cp_id, locale: I18n.locale))
    end

    context "検索した文字列がヒットする場合" do
      before do
        user.charts.create! do |c|
          c.name = "test1"
        end

        user.charts.create! do |c|
          c.name = "test2"
        end
      end

      it "該当するチャート名のみが一覧に表示される", :js do # inputイベント発火(send_keys利用)のために要js
        visit mypage_charts_path(locale: I18n.locale)
        field = find('input[name="q[name_cont]"]')
        field.send_keys("test1")
        expect(page).to have_content("test1")
        expect(page).not_to have_content("test2")
      end

      it "該当するノートを持つチャートのみが一覧に表示される", :js do
        visit mypage_charts_path(locale: I18n.locale)
        field = find('input[name="q[name_cont]"]')
        field.send_keys("test1")
        expect(page).to have_content("test1")
        expect(page).not_to have_content("test2")
      end
    end

    context "どのチャート名・ノートにも該当しないランダム文字列で検索した場合" do
      it "表示するチャートがない旨が表示される", :js do
        visit mypage_charts_path(locale: I18n.locale)
        field = find('input[name="q[name_cont]"]')
        field.send_keys("Hello, world!!")
        expect(page).to have_content(I18n.t("mypage.charts.index.nothing_here"))
      end
    end
  end

  describe "showアクション" do
    it "一覧ページへ戻るリンクが機能する" do
      visit mypage_chart_path(id: cp_id, locale: I18n.locale)
      click_link(I18n.t("defaults.back"))
      expect(page).to have_current_path(mypage_charts_path(locale: I18n.locale))
    end
  end

  describe "newアクション" do
    it "新規作成フォームが表示される" do
      visit new_mypage_chart_path(locale: I18n.locale)
      expect(page).to have_field(I18n.t("helpers.label.chart_name"))
      expect(page).to have_button(I18n.t("helpers.submit.create"))
    end

    it "一覧ページへ戻るリンクが機能する" do
      visit new_mypage_chart_path(locale: I18n.locale)
      click_link(I18n.t("defaults.back"))
      expect(page).to have_current_path(mypage_charts_path(locale: I18n.locale))
    end
  end

  describe "editアクション" do
    before do
      user.charts.create! do |c|
        c.name = "test1"
      end
    end

    it "編集フォームが表示される", :js do
      visit mypage_charts_path(locale: I18n.locale)

      # カードをクリックして詳細画面に遷移
      expect(page).to have_css('a[data-turbo-frame="_top"]')
      find('a[data-turbo-frame="_top"]', match: :first).click

      # 変更ボタンをクリックして、チャート名編集フォームを表示させる
      click_link(I18n.t("defaults.edit"))

      expect(page).to have_field("chart_name", with: "test1")
      expect(page).to have_button(I18n.t("helpers.submit.update"))
      expect(page).to have_link(I18n.t("defaults.cancel"))
    end

    it "キャンセルボタンが機能する(編集フォームが閉じる)", :js do
      visit mypage_chart_path(id: cp_id, locale: I18n.locale)

      # 変更ボタンをクリックして、チャート名編集フォームを表示させる
      click_link(I18n.t("defaults.edit"))

      expect(page).to have_field("chart_name", with: /preset_\d{8}-\d{6}/)
      expect(page).to have_button(I18n.t("helpers.submit.update"))
      expect(page).to have_link(I18n.t("defaults.cancel"))

      # キャンセルボタンをクリック
      click_link(I18n.t("defaults.cancel"))

      expect(page).not_to have_field("chart_name", with: /preset_\d{8}-\d{6}/)
      expect(page).not_to have_button(I18n.t("helpers.submit.update"))
      expect(page).not_to have_link(I18n.t("defaults.cancel"))

      expect(page).to have_content(/preset_\d{8}-\d{6}/)
      expect(page).to have_link(I18n.t("defaults.edit"))
      expect(page).to have_link(I18n.t("defaults.delete"))
    end
  end

  describe "createアクション" do
    context "有効なデータの場合" do
      it "チャートが作成できる" do
        visit new_mypage_chart_path(locale: I18n.locale)
        fill_in I18n.t("helpers.label.chart_name"), with: "test1"
        expect {
          click_button(I18n.t("helpers.submit.create"))
        }.to change(user.charts, :count).by(1)
        expect(page).to have_current_path(mypage_charts_path(locale: I18n.locale))
        expect(page).to have_content("test1")
        expect(page).to have_content(I18n.t("defaults.flash_messages.created", item: Chart.model_name.human))
      end
    end

    context "チャート名が空の場合" do
      it "チャートの作成に失敗する" do
        visit new_mypage_chart_path(locale: I18n.locale)
        expect {
          click_button(I18n.t("helpers.submit.create"))
        }.to change(user.charts, :count).by(0)
        expect(page).to have_current_path(mypage_charts_path(locale: I18n.locale))
        expect(page).to have_content(I18n.t("defaults.flash_messages.not_created", item: Chart.model_name.human))
        # #{Chart.human_attribute_name(:name)} = I18n.t("activerecord.attributes.chart.name")
        expect(page).to have_content("#{Chart.human_attribute_name(:name)}#{I18n.t('errors.messages.blank')}")
      end
    end

    context "チャート名が既存データと重複する場合" do
        let!(:chart) do
          user.charts.create! do |c|
            c.name = "test1"
          end
        end

      it "チャートの作成に失敗する" do
        visit new_mypage_chart_path(locale: I18n.locale)
        fill_in I18n.t("helpers.label.chart_name"), with: "test1"
        expect {
          click_button(I18n.t("helpers.submit.create"))
        }.to change(user.charts, :count).by(0)
        expect(page).to have_current_path(mypage_charts_path(locale: I18n.locale))
        expect(page).to have_content(I18n.t("defaults.flash_messages.not_created", item: Chart.model_name.human))
        expect(page).to have_content("#{Chart.human_attribute_name(:name)}#{I18n.t('errors.messages.taken')}")
      end
    end
  end
end
