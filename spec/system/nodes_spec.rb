require 'rails_helper'

RSpec.describe "Nodes", type: :system do
  before do
    omniauth_login
    user = User.find_by(email: "tester1@example.com")
    @chart = user.charts.first

    # ノード作成まで済ませたテクニック
    @technique1 = user.techniques.create! do |t|
      t.set_name_for("test1")
      t.note = "test note!1"
    end
    @node = @chart.nodes.create!(technique: @technique1)

    # ノード作成は行なっていないテクニック
    @technique2 = user.techniques.create! do |t|
      t.set_name_for("test2")
      t.note = "test note!2"
    end
  end

  describe "newアクション" do
    it "新規作成ボタンをクリックすると、ルートノード作成フォームが表示される", :js do
      visit mypage_chart_path(id: @chart.id, locale: I18n.locale)
      click_button(I18n.t("mypage.charts.show.create_nodes"))

      within('#node-drawer') do
        expect(page).to have_select('node[roots][]')
        expect(page).to have_button(I18n.t("helpers.submit.create"))
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
        expect(page).not_to have_button(I18n.t("helpers.submit.create"))
      end
    end
  end

  describe "editアクション" do
    it "ノードをクリックすると、ドロワーが開かれて編集フォームが表示される", :js do
      visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

      click_node(@node.id)

      within('#node-drawer') do
        expect(page).to have_field(I18n.t("helpers.label.technique_name"), with: @technique1.name_for)
        expect(page).to have_field(I18n.t("helpers.label.note"), with: @technique1.note)
        expect(page).to have_select(I18n.t("helpers.label.category"), selected: I18n.t("enums.category.nil"))
      end
    end

    it "背景をクリックすると、ドロワーが閉じる", :js do
      visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

      click_node(@node.id)

      # 背景をクリックする
      find(".drawer-overlay").click

      within('#node-drawer') do
        expect(page).not_to have_field(I18n.t("helpers.label.technique_name"), with: @technique1.name_for)
        expect(page).not_to have_field(I18n.t("helpers.label.note"), with: @technique1.note)
        expect(page).not_to have_select(I18n.t("helpers.label.category"), selected: I18n.t("enums.category.nil"))
      end
    end
  end

  describe "createアクション" do
    context "有効なデータの場合" do
      it "新しいルートノードが作成される", :js do
        visit mypage_chart_path(id: @chart.id, locale: I18n.locale)
        click_button(I18n.t("mypage.charts.show.create_nodes"))

        select @technique2.name_for, from: "node[roots][]"
        expect {
          click_button(I18n.t("helpers.submit.create"))
        }.to change(@chart.nodes, :count).by(1)
        expect(page).to have_current_path(mypage_chart_path(id: @chart.id, locale: I18n.locale))
        expect(page).to have_content(I18n.t("defaults.flash_messages.created", item: I18n.t("terms.root_nodes")))

        # チャート描写用のJSONファイルを確認
        visit api_v1_chart_path(id: @chart.id, locale: I18n.locale)
        expect(page).to have_content(@technique2.name_for)
      end
    end

    context "何のテクニックを指定しなかった場合", :js do
      it "ルートノードの作成に失敗する" do
        visit mypage_chart_path(id: @chart.id, locale: I18n.locale)
        click_button(I18n.t("mypage.charts.show.create_nodes"))

        expect {
          click_button(I18n.t("helpers.submit.create"))
        }.to change(@chart.nodes, :count).by(0)

        expect(page).to have_current_path(mypage_chart_path(id: @chart.id, locale: I18n.locale))
        expect(page).to have_content(I18n.t("defaults.flash_messages.multiple_select", item: I18n.t("terms.root_nodes")))

        # チャート描写用のJSONファイルを確認
        visit api_v1_chart_path(id: @chart.id, locale: I18n.locale)
        expect(page).not_to have_content(@technique2.name_for)
      end
    end

    it "既存のルートノードを指定しても重複作成されない", :js do
      visit mypage_chart_path(id: @chart.id, locale: I18n.locale)
      click_button(I18n.t("mypage.charts.show.create_nodes"))


      input = find('.ts-control input')
      input.send_keys('test1')

      expect(page).to have_css('.ts-dropdown .create', text: /Add .*test1/i)
      find('.ts-dropdown .create', text: /Add .*test1/i).click
      select @technique2.name_for, from: "node[roots][]"

      # ↓Tom Selectのcreateで、technique1のみ登録試行する場合は、プルダウンを閉じる必要あり。
      # 空白をクリックして、登録ボタンを覆ってしまっているプルダウンを閉じる
      # within('#node-drawer') do
      #  find('form').click
      #  expect(page).to have_no_css('.ts-dropdown')
      # end

      # technique2のみがノードとして増える。ルートノードとして既存のtechnique1は増えない。
      expect {
        click_button(I18n.t("helpers.submit.create"))
      }.to change(@chart.nodes, :count).by(1)

      expect(page).to have_current_path(mypage_chart_path(id: @chart.id, locale: I18n.locale))
      expect(page).to have_content(I18n.t("defaults.flash_messages.created", item: I18n.t("terms.root_nodes")))

      # チャート描写用のJSONファイルを確認
      visit api_v1_chart_path(id: @chart.id, locale: I18n.locale)
      expect(page).to have_content(@technique1.name_for)
      expect(page).to have_content(@technique2.name_for)
    end
  end

  describe "updateアクション" do
  end

  describe "destroyアクション" do
  end
end
