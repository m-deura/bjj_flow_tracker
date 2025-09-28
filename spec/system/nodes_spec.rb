require 'rails_helper'

RSpec.describe "Nodes", type: :system do
  before do
    omniauth_login
    user = User.find_by(email: "tester1@example.com")
    @chart = user.charts.first
    @technique = user.techniques.create! do |t|
      t.set_name_for("test1")
      t.note = "test note!1"
    end
    @node = @chart.nodes.create!(technique: @technique)
  end

  describe "newアクション" do
    it "新規作成ボタンをクリックすると、ルートノード作成フォームが表示される", :js do
      visit mypage_chart_path(id: @chart.id, locale: I18n.locale)
      click_button(I18n.t("mypage.charts.show.create_nodes"))

      within('#node-drawer') do
        expect(page).to have_select('node[roots][]')
      end
    end

    it "背景をクリックすると、ドロワーが閉じる", :js do
      visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

      # ノードをクリックしてドロワーを開く
      click_button(I18n.t("mypage.charts.show.create_nodes"))
      # 背景をクリックする
      find(".drawer-overlay").click

      within('#node-drawer') do
        expect(page).not_to have_select('node[roots][]')
      end
    end
  end

  describe "editアクション" do
    it "ノードをクリックすると、ドロワーが開かれて編集フォームが表示される", :js do
      visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

      # クリック発火（node.id はテストデータに合わせる）
      # カスタムイベント生成＋発火を同時実行
      page.execute_script(<<~JS, @node.id)
        window.dispatchEvent(new CustomEvent('test:click-node', { detail: { id: arguments[0] } }));
      JS

      within('#node-drawer') do
        expect(page).to have_field(I18n.t("helpers.label.technique_name"), with: @technique.name_for)
        expect(page).to have_field(I18n.t("helpers.label.note"), with: @technique.note)
        expect(page).to have_select(I18n.t("helpers.label.category"), selected: I18n.t("enums.category.nil"))
      end
    end

    it "背景をクリックすると、ドロワーが閉じる", :js do
      visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

      # ノードをクリックしてドロワーを開く
      page.execute_script(<<~JS, @node.id)
        window.dispatchEvent(new CustomEvent('test:click-node', { detail: { id: arguments[0] } }));
      JS

      # 背景をクリックする
      find(".drawer-overlay").click

      within('#node-drawer') do
        expect(page).not_to have_field(I18n.t("helpers.label.technique_name"), with: @technique.name_for)
        expect(page).not_to have_field(I18n.t("helpers.label.note"), with: @technique.note)
        expect(page).not_to have_select(I18n.t("helpers.label.category"), selected: I18n.t("enums.category.nil"))
      end
    end
  end

  describe "createアクション" do
  end

  describe "updateアクション" do
  end

  describe "destroyアクション" do
  end
end
