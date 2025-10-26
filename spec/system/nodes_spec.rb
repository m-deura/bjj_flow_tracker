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

    @technique3 = user.techniques.create! do |t|
      t.set_name_for("test3")
      t.note = "test note!3"
    end

    # @technique1 と @technique2 を繋ぐ遷移条件
    Transition.create!(from: @technique1, to: @technique2, trigger: "test trigger")
  end

  describe "indexアクション(チャート描写用JSON)" do
    it "期待するJSONスキーマで nodes/edges を返す" do
      visit api_v1_chart_path(id: @chart.id)

      expect(page.status_code).to eq 200
      json = JSON.parse(page.text)

      # nodes の検査
      np_count = NodePreset.count
      nodes = json["nodes"].select { |n| n.dig("data", "label").present? && n["id"].present? }
      expect(nodes.size).to eq np_count + 1 # テスト冒頭で作成した @technique1 の分 +1
      expect(nodes.map { |n| n.dig("id") }).to all(be_a(String).and(be_present))
      expect(nodes.map { |n| n.dig("data", "label") }).to all(be_a(String).and(be_present))

      # edges の検査
      edges = json["edges"].select { |e| e["source"].present? && e["target"].present? }
      ep_count = EdgePreset.count
      expect(edges.size).to eq ep_count
      expect(edges.map { |e| e.dig("source") }).to all(be_a(String).and(be_present))
      expect(edges.map { |e| e.dig("target") }).to all(be_a(String).and(be_present))

      # 許可外のカテゴリーが混じっていないこと
      allowed = Technique.categories.keys
      cats = nodes.map { |n| n.dig("data", "category") }
      expect(cats.compact).to all(be_in(allowed))
    end
  end

  describe "newアクション" do
    it "新規作成ボタンをクリックすると、ルートノード作成フォームが表示される", :js do
      visit mypage_chart_path(id: @chart.id, locale: I18n.locale)
      click_button(I18n.t("mypage.charts.show.create_nodes"))

      within('#node-drawer') do
        expect(page).to have_select('root_nodes')
        expect(page).to have_button(I18n.t("helpers.submit.create"))
      end
    end

    it "バツボタンをクリックすると、ドロワーが閉じる", :js do
      visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

      # ノードをクリックしてドロワーを開く
      click_button(I18n.t("mypage.charts.show.create_nodes"))
      # 背景クリックだと他要素と被ってクリックに失敗することがあるので、バツボタンをクリック
      find('aside label[data-action*="chart#closeDrawer"]').click

      within('#node-drawer') do
        expect(page).not_to have_select('root_nodes')
        expect(page).not_to have_button(I18n.t("helpers.submit.create"))
      end
    end
  end

  describe "editアクション" do
    it "ステップガイドが開始できる", :js do
      visit mypage_chart_path(id: @chart.id, locale: I18n.locale)
      click_node(@node.id)

      find(:css, '[data-action~="click->step-guide#startNodeGuide"]').click
      expect(page).to have_css('.introjs-tour')
    end

    # ロケールファイル間のi18nキー非対称性は、CIで実行される i18n-tasks health によって検知されるのでテストは行わない。
    it "ロケールファイルに書いたガイド数と実際のガイド数が一致する", :js do
      visit mypage_chart_path(id: @chart.id, locale: I18n.locale)
      click_node(@node.id)

      count_steps(
        i18n_scope: [ "#{I18n.locale}", "guides", "node" ],
        start_selector: '[data-action~="click->step-guide#startNodeGuide"]',
      )
    end

    it "ノードをクリックすると、ドロワーが開かれて編集フォームが表示される", :js do
      visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

      click_node(@node.id)

      within('#node-drawer') do
        expect(page).to have_field(I18n.t("helpers.label.technique_name"), with: @technique1.name_for)
        expect(page).to have_field(I18n.t("helpers.label.note"), with: @technique1.note)
        expect(page).to have_select(I18n.t("helpers.label.category"), selected: I18n.t("enums.category.nil"))
        # 遷移条件編集フォームは表示されていないことを確認
        expect(page).not_to have_content(I18n.t("helpers.label.triggers"))
      end
    end

    it "セレクトボックスで展開先テクニックを選ぶと、遷移条件編集フォームが表示される", :js do
      visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

      click_node(@node.id)

      within('#node-drawer') do
        expect(page).to have_field(I18n.t("helpers.label.technique_name"), with: @technique1.name_for)
        expect(page).to have_field(I18n.t("helpers.label.note"), with: @technique1.note)
        expect(page).to have_select(I18n.t("helpers.label.category"), selected: I18n.t("enums.category.nil"))

        # 遷移条件編集フォームは表示されていないことを確認
        expect(page).not_to have_content(I18n.t("helpers.label.triggers"))
        expect(page).not_to have_field("node_edit_form[triggers][#{@technique2.id}]")
        expect(page).not_to have_css("span.badge", text: @technique2.name_for)
      end

      # セレクトボックスで @technique2 を選ぶ
      select @technique2.name_for, from: "children_nodes"

      within('#node-drawer') do
        expect(page).to have_field(I18n.t("helpers.label.technique_name"), with: @technique1.name_for)
        expect(page).to have_field(I18n.t("helpers.label.note"), with: @technique1.note)
        expect(page).to have_select(I18n.t("helpers.label.category"), selected: I18n.t("enums.category.nil"))

        # @technique2 に対応した遷移条件編集フォームが表示される
        expect(page).to have_content(I18n.t("helpers.label.triggers"))
        expect(page).to have_field("node_edit_form[triggers][#{@technique2.id}]")
        expect(page).to have_css("span.badge", text: @technique2.name_for)
      end
    end

    context "展開先テクニックが登録されている場合" do
      before do # @technique1 の展開先として @technique2 を登録
        node2 = @chart.nodes.create!(technique: @technique2)
        Edge.create!(from: @node, to: node2, flow: 1)
      end

      it "編集ページに遷移条件編集フォームが表示される", :js do
        visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

        click_node(@node.id)

        within('#node-drawer') do
          expect(page).to have_content(I18n.t("helpers.label.triggers"))
          expect(page).to have_field("node_edit_form[triggers][#{@technique2.id}]", with: "test trigger")
          expect(page).to have_css("span.badge", text: @technique2.name_for)
        end
      end

      it "登録済みの展開先テクニックをセレクトボックスから外すと、対応する遷移条件編集フォームが消える", :js do
        visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

        click_node(@node.id)

        within('#node-drawer') do
          expect(page).to have_content(I18n.t("helpers.label.triggers"))
          expect(page).to have_field("node_edit_form[triggers][#{@technique2.id}]", with: "test trigger")
          expect(page).to have_css("span.badge", text: @technique2.name_for)
        end

        # technique2を展開先テクニックから削除
        within('turbo-frame#node-drawer') do
          find('#children_nodes-ts-control').send_keys(:backspace)
        end

        within('#node-drawer') do
          expect(page).not_to have_content(I18n.t("helpers.label.triggers"))
          expect(page).not_to have_field("node_edit_form[triggers][#{@technique2.id}]", with: "test trigger")
          expect(page).not_to have_css("span.badge", text: @technique2.name_for)
        end
      end
    end

    it "バツボタンをクリックすると、ドロワーが閉じる", :js do
      visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

      click_node(@node.id)
      # バツボタンをクリック
      find('aside label[data-action*="chart#closeDrawer"]').click


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

        select @technique2.name_for, from: "root_nodes"
        expect {
          click_button(I18n.t("helpers.submit.create"))
          expect(page).to have_current_path(mypage_chart_path(id: @chart.id, locale: I18n.locale))
          expect(page).to have_content(I18n.t("defaults.flash_messages.created", item: I18n.t("terms.root_nodes")))
        }.to change(@chart.nodes, :count).by(1)

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

    it "既存のルートノードを指定しても重複作成されない(差分更新ができる)", :js do
      visit mypage_chart_path(id: @chart.id, locale: I18n.locale)
      click_button(I18n.t("mypage.charts.show.create_nodes"))


      input = find('.ts-control input')
      input.send_keys('test1')

      expect(page).to have_css('.ts-dropdown .create', text: /Add .*test1/i)
      find('.ts-dropdown .create', text: /Add .*test1/i).click
      select @technique2.name_for, from: "root_nodes"

      # ↓Tom Selectのcreateで、technique1のみ登録試行する場合は、プルダウンを閉じる必要あり。
      # 空白をクリックして、登録ボタンを覆ってしまっているプルダウンを閉じる
      # within('#node-drawer') do
      #  find('form').click
      #  expect(page).to have_no_css('.ts-dropdown')
      # end

      # technique2のみがノードとして増える。ルートノードとして既存のtechnique1は増えない。
      expect {
        click_button(I18n.t("helpers.submit.create"))
        expect(page).to have_current_path(mypage_chart_path(id: @chart.id, locale: I18n.locale))
        expect(page).to have_content(I18n.t("defaults.flash_messages.created", item: I18n.t("terms.root_nodes")))
      }.to change(@chart.nodes, :count).by(1)

      # チャート描写用のJSONファイルを確認
      visit api_v1_chart_path(id: @chart.id, locale: I18n.locale)
      expect(page).to have_content(@technique1.name_for)
      expect(page).to have_content(@technique2.name_for)
    end
  end

  describe "updateアクション" do
    context "有効なデータの場合" do
      it "テクニック/展開先テクニック/遷移条件の同時更新できる", :js do
        visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

        # ノードをクリックしてドロワーを開く
        click_node(@node.id)

        fill_in I18n.t("helpers.label.technique_name"), with: "retest4"
        fill_in I18n.t("helpers.label.note"), with: "retest note!4"
        select I18n.t("enums.category.submission"), from: I18n.t("helpers.label.category")
        select @technique2.name_for, from: "children_nodes"
        select @technique3.name_for, from: "children_nodes"

        # @technique2 と @technique 3 に対応した遷移条件編集フォームが表示される
        expect(page).to have_field("node_edit_form[triggers][#{@technique2.id}]", with: "test trigger")
        expect(page).to have_field("node_edit_form[triggers][#{@technique3.id}]")

        # 遷移条件の上書きor追加
        fill_in "node_edit_form[triggers][#{@technique2.id}]", with: "test trigger! 2"
        fill_in "node_edit_form[triggers][#{@technique3.id}]", with: "test trigger! 3"

        # 保存ボタンをクリック
        click_button(I18n.t("helpers.submit.submit"))

        expect(page).to have_current_path(mypage_chart_path(id: @chart.id, locale: I18n.locale))
        expect(page).to have_content(I18n.t("defaults.flash_messages.updated", item: Node.model_name.human))

        # 再びノードをクリックしてドロワーを開く
        click_node(@node.id)

        within('#node-drawer') do
          expect(page).to have_field(I18n.t("helpers.label.technique_name"), with: "retest4")
          expect(page).to have_field(I18n.t("helpers.label.note"), with: "retest note!4")
          expect(page).to have_select(I18n.t("helpers.label.category"), selected: I18n.t("enums.category.submission"))
          expect(page).to have_select("children_nodes",
                                      selected: [ @technique2.name_for, @technique3.name_for ]
                                     )
          expect(page).to have_field("node_edit_form[triggers][#{@technique2.id}]", with: "test trigger! 2")
          expect(page).to have_field("node_edit_form[triggers][#{@technique3.id}]", with: "test trigger! 3")
        end
      end

      it "展開先テクニックの差分更新ができる", :js do
        visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

        # ノードをクリックしてドロワーを開く
        click_node(@node.id)

        select @technique2.name_for, from: "children_nodes"
        click_button(I18n.t("helpers.submit.submit"))

        expect(page).to have_current_path(mypage_chart_path(id: @chart.id, locale: I18n.locale))
        expect(page).to have_content(I18n.t("defaults.flash_messages.updated", item: Node.model_name.human))

        # 再びノードをクリックしてドロワーを開く
        click_node(@node.id)

        # technique2を削除して、techniaue3を追加
        within('turbo-frame#node-drawer') do
          find('#children_nodes-ts-control').send_keys(:backspace)
        end
        select @technique3.name_for, from: "children_nodes"
        click_button(I18n.t("helpers.submit.submit"))

        expect(page).to have_current_path(mypage_chart_path(id: @chart.id, locale: I18n.locale))
        expect(page).to have_content(I18n.t("defaults.flash_messages.updated", item: Node.model_name.human))

        # 再びノードをクリックしてドロワーを開く
        click_node(@node.id)

        # technique3のみが表示されていること
        within('turbo-frame#node-drawer') do
          expect(page).to have_select("children_nodes",
                                      selected: [ @technique3.name_for ]
                                     )
        end
      end

      it "展開先テクニックが空でも更新できる", :js do
        visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

        # ノードをクリックしてドロワーを開く
        click_node(@node.id)

        fill_in I18n.t("helpers.label.technique_name"), with: "retest4"
        fill_in I18n.t("helpers.label.note"), with: "retest note!4"
        select I18n.t("enums.category.submission"), from: I18n.t("helpers.label.category")
        click_button(I18n.t("helpers.submit.submit"))

        expect(page).to have_current_path(mypage_chart_path(id: @chart.id, locale: I18n.locale))
        expect(page).to have_content(I18n.t("defaults.flash_messages.updated", item: Node.model_name.human))

        # 再びノードをクリックしてドロワーを開く
        click_node(@node.id)

        within('#node-drawer') do
          expect(page).to have_field(I18n.t("helpers.label.technique_name"), with: "retest4")
          expect(page).to have_field(I18n.t("helpers.label.note"), with: "retest note!4")
          expect(page).to have_select(I18n.t("helpers.label.category"), selected: I18n.t("enums.category.submission"))
        end
      end

      it "遷移条件が空でも更新できる", :js do
        visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

        # ノードをクリックしてドロワーを開く
        click_node(@node.id)

        fill_in I18n.t("helpers.label.technique_name"), with: "retest4"
        fill_in I18n.t("helpers.label.note"), with: "retest note!4"
        select I18n.t("enums.category.submission"), from: I18n.t("helpers.label.category")
        select @technique2.name_for, from: "children_nodes"

        # @technique2 に対応した遷移条件編集フォームが表示される
        expect(page).to have_field("node_edit_form[triggers][#{@technique2.id}]", with: "test trigger")

        # 遷移条件を空文字で上書き
        fill_in "node_edit_form[triggers][#{@technique2.id}]", with: ""

        # 保存ボタンをクリック
        click_button(I18n.t("helpers.submit.submit"))

        expect(page).to have_current_path(mypage_chart_path(id: @chart.id, locale: I18n.locale))
        expect(page).to have_content(I18n.t("defaults.flash_messages.updated", item: Node.model_name.human))

        # 再びノードをクリックしてドロワーを開く
        click_node(@node.id)

        within('#node-drawer') do
          expect(page).to have_field(I18n.t("helpers.label.technique_name"), with: "retest4")
          expect(page).to have_field(I18n.t("helpers.label.note"), with: "retest note!4")
          expect(page).to have_select(I18n.t("helpers.label.category"), selected: I18n.t("enums.category.submission"))
          expect(page).to have_select("children_nodes",
                                      selected: [ @technique2.name_for ]
                                     )
          expect(page).to have_field("node_edit_form[triggers][#{@technique2.id}]", with: "")
        end
      end
    end

    context "テクニック名が空の場合" do
      it "更新に失敗する", :js  do
        visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

        # ノードをクリックしてドロワーを開く
        click_node(@node.id)

        fill_in I18n.t("helpers.label.technique_name"), with: ""
        fill_in I18n.t("helpers.label.note"), with: "retest note!4"
        select I18n.t("enums.category.submission"), from: I18n.t("helpers.label.category")
        click_button(I18n.t("helpers.submit.submit"))

        expect(page).to have_current_path(mypage_chart_path(id: @chart.id, locale: I18n.locale))
        expect(page).to have_content(I18n.t("defaults.flash_messages.not_updated", item: Node.model_name.human))
        expect(page).to have_content("#{Technique.human_attribute_name(:name_ja)}#{I18n.t('errors.messages.blank')}")

        # 再びノードをクリックしてドロワーを開く
        click_node(@node.id)

        within('#node-drawer') do
          expect(page).to have_field(I18n.t("helpers.label.technique_name"), with: "test1")
          expect(page).to have_field(I18n.t("helpers.label.note"), with: "test note!1")
          expect(page).to have_select(I18n.t("helpers.label.category"), selected: I18n.t("enums.category.nil"))
        end
      end
    end

    context "テクニック名が既存のものと重複していた場合" do
      before do
        @chart.nodes.create!(technique: @technique2)
      end

      it "更新に失敗する", :js do
        visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

        # ノードをクリックしてドロワーを開く
        click_node(@node.id)

        fill_in I18n.t("helpers.label.technique_name"), with: "test2"
        fill_in I18n.t("helpers.label.note"), with: "retest note!2"
        select I18n.t("enums.category.submission"), from: I18n.t("helpers.label.category")
        click_button(I18n.t("helpers.submit.submit"))

        expect(page).to have_current_path(mypage_chart_path(id: @chart.id, locale: I18n.locale))
        expect(page).to have_content(I18n.t("defaults.flash_messages.not_updated", item: Node.model_name.human))
        expect(page).to have_content("#{Technique.human_attribute_name(:name_ja)}#{I18n.t('errors.messages.taken')}")

        # 再びノードをクリックしてドロワーを開く
        click_node(@node.id)

        within('#node-drawer') do
          expect(page).to have_field(I18n.t("helpers.label.technique_name"), with: "test1")
          expect(page).to have_field(I18n.t("helpers.label.note"), with: "test note!1")
          expect(page).to have_select(I18n.t("helpers.label.category"), selected: I18n.t("enums.category.nil"))
        end
      end
    end
  end

  describe "destroyアクション" do
    before do
      @node2 = Node.create!(chart_id: @chart.id, technique_id: @technique2.id)
      @node3 = Node.create!(chart_id: @chart.id, technique_id: @technique3.id)
      Edge.create!(from_id: @node.id, to_id: @node2.id, flow: 1)
      Edge.create!(from_id: @node2.id, to_id: @node3.id, flow: 1)
    end

    context "削除ボタンをクリックした場合" do
        it "当該ノードのみが削除される(子ノードは削除されない)こと。", :js do
        visit mypage_chart_path(id: @chart.id, locale: I18n.locale)

        # @node の子ノードとして @node2 が登録されていることを確認
        click_node(@node.id)

        within('#node-drawer') do
          expect(page).to have_field(I18n.t("helpers.label.technique_name"), with: "test1")
          expect(page).to have_field(I18n.t("helpers.label.note"), with: "test note!1")
          expect(page).to have_select(I18n.t("helpers.label.category"), selected: I18n.t("enums.category.nil"))
          expect(page).to have_select("children_nodes",
                                      selected: [ @technique2.name_for ]
                                     )
        end

        # バツボタンをクリック
        find('aside label[data-action*="chart#closeDrawer"]').click

        # @node2 の子ノードとして @node3 が登録されていることを確認
        click_node(@node2.id)

        within('#node-drawer') do
          expect(page).to have_field(I18n.t("helpers.label.technique_name"), with: "test2")
          expect(page).to have_field(I18n.t("helpers.label.note"), with: "test note!2")
          expect(page).to have_select(I18n.t("helpers.label.category"), selected: I18n.t("enums.category.nil"))
          expect(page).to have_select("children_nodes",
                                      selected: [ @technique3.name_for ]
                                     )
        end

        # @node2 の削除ボタンをクリックする
        expect {
          accept_confirm(I18n.t("defaults.delete_confirm")) do
            click_link(I18n.t("defaults.delete_item", item: Node.model_name.human))
          end
          expect(page).to have_content(I18n.t("defaults.flash_messages.deleted", item: Node.model_name.human))
        }.to change(@chart.nodes, :count).by(-1)

        # @node の子ノードとして登録されていた @node2 が消えていることを確認
        click_node(@node.id)

        within('#node-drawer') do
          expect(page).to have_field(I18n.t("helpers.label.technique_name"), with: "test1")
          expect(page).to have_field(I18n.t("helpers.label.note"), with: "test note!1")
          expect(page).to have_select(I18n.t("helpers.label.category"), selected: I18n.t("enums.category.nil"))
          expect(page).to have_select("children_nodes",
                                      selected: []
                                     )
        end

        # バツボタンをクリック
        find('aside label[data-action*="chart#closeDrawer"]').click

        # @node2 の子ノードとして登録されていた @node3 は削除されない
        # （ドロワーを開くことができて、ドロワー内に編集フィールドがあることを確認できる）
        click_node(@node3.id)
      end
    end
  end
end
