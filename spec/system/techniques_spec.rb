require 'rails_helper'

RSpec.describe "Techniques", type: :system do
  before do
    omniauth_login
  end

  let(:user) { User.find_by(email: "tester1@example.com") }

  # pending "add some scenarios (or delete) #{__FILE__}"

  describe "indexアクション" do
    it "ステップガイドが開始できる", :js do
      visit mypage_techniques_path(locale: I18n.locale)
      find(:css, '[data-action~="click->step-guide#startTechniqueGuide"]').click
      expect(page).to have_css('.introjs-tour')
    end

    # ロケールファイル間のi18nキー非対称性は、CIで実行される i18n-tasks health によって検知されるのでテストは行わない。
    it "ロケールファイルに書いたガイド数と実際のガイド数が一致する", :js do
      visit mypage_techniques_path(locale: I18n.locale)
      # ガイド開始
      find(:css, '[data-action~="click->step-guide#startTechniqueGuide"]').click

      # Next or Doneボタンのクリック数をカウント
      clicks = 0

      loop do
        # Nextボタンが存在し、かつ有効か確認
        has_next = page.has_css?('.introjs-nextbutton')
        break unless has_next

        # 最終ステップガイドの"Done"ボタンを含む
        next_btn = find('.introjs-nextbutton')

        # Next or Done ボタンをクリック
        next_btn.click
        clicks += 1
      end

      # ロケールファイルからガイド用のI18nキーを取り出してカウント
      path = Rails.root.join("config/locales/guides/#{I18n.locale}.yml")
      hash = YAML.safe_load(File.read(path))
      steps = hash.dig("#{I18n.locale}", "guides", "technique", "default").keys.grep(/\Astep\d+\z/)

      expect(steps.size).to eq clicks
    end

    it "プリセットのテクニックが確認できる" do
      visit mypage_techniques_path(locale: I18n.locale)
      expect(page).to have_content("マウント")
    end

    context "登録されたテクニックがない(プリセットを含めテクニックを全削除した)場合" do
      before do
        Edge.destroy_all
        user.charts.find_each do |chart|
          # chart.edges.delete_all #まだリレーションを作成していないためコメントアウト
          chart.nodes.delete_all
        end
        user.techniques.delete_all
      end

      it "表示するテクニックがない旨が表示される" do
        visit mypage_techniques_path(locale: I18n.locale)
        expect(page).to have_content(I18n.t("mypage.techniques.index.nothing_here"))
      end

      # ロケールファイル間のi18nキー非対称性は、CIで実行される i18n-tasks health によって検知されるのでテストは行わない。
      it "ロケールファイルに書いたガイド数と実際のガイド数が一致する", :js do
        visit mypage_techniques_path(locale: I18n.locale)
        # ガイド開始
        find(:css, '[data-action~="click->step-guide#startTechniqueGuide"]').click

        # Next or Doneボタンのクリック数をカウント
        clicks = 0

        loop do
          # Nextボタンが存在し、かつ有効か確認
          has_next = page.has_css?('.introjs-nextbutton')
          break unless has_next

          # 最終ステップガイドの"Done"ボタンを含む
          next_btn = find('.introjs-nextbutton')

          # Next or Done ボタンをクリック
          next_btn.click
          clicks += 1
        end

        # ロケールファイルからガイド用のI18nキーを取り出してカウント
        path = Rails.root.join("config/locales/guides/#{I18n.locale}.yml")
        hash = YAML.safe_load(File.read(path))
        steps = hash.dig("#{I18n.locale}", "guides", "technique", "zero_state").keys.grep(/\Astep\d+\z/)

        expect(steps.size).to eq clicks
      end
    end

    it "新規作成ページへのリンクが機能する" do
      visit mypage_techniques_path(locale: I18n.locale)
      click_link(I18n.t("defaults.create"))
      expect(page).to have_current_path(new_mypage_technique_path(locale: I18n.locale))
    end

    context "検索した文字列がヒットする場合" do
      before do
        user.techniques.create! do |t|
          t.set_name_for("test1")
          t.note = "test note!1"
          t.category = "submission"
        end

        user.techniques.create! do |t|
          t.set_name_for("test2")
          t.note = "test note!2"
          t.category = "control"
        end
      end

      it "該当するテクニック名のみが一覧に表示される", :js do # inputイベント発火(send_keys利用)のために要js
        visit mypage_techniques_path(locale: I18n.locale)
        field = find('input[name="q[name_ja_or_name_en_or_note_cont]"]')
        field.send_keys("test1")
        expect(page).to have_content("test1")
        expect(page).not_to have_content("test2")
      end

      it "該当するノートを持つテクニックのみが一覧に表示される", :js do
        visit mypage_techniques_path(locale: I18n.locale)
        field = find('input[name="q[name_ja_or_name_en_or_note_cont]"]')
        field.send_keys("test note!1")
        expect(page).to have_content("test1")
        expect(page).not_to have_content("test2")
      end
    end

    context "どのテクニック名・ノートにも該当しないランダム文字列で検索した場合" do
      it "表示するテクニックがない旨が表示される", :js do
        visit mypage_techniques_path(locale: I18n.locale)
        field = find('input[name="q[name_ja_or_name_en_or_note_cont]"]')
        field.send_keys("Hello, world!!")
        expect(page).to have_content(I18n.t("mypage.techniques.index.nothing_here"))
      end
    end

    context "カテゴリーフィルタをかけた場合" do
      it "選択したカテゴリのテクニックのみが表示される", :js do
        visit mypage_techniques_path(locale: I18n.locale)
        submission = I18n.t("enums.category.submission")
        control = I18n.t("enums.category.control")
        find(:css, %(input[type="checkbox"][aria-label="#{submission}"])).click

        # サブミットカテゴリーのテクニックのみが表示される
        expect(page).to have_content(submission)
        expect(page).not_to have_content(control)
      end

      it "リセットボタンが機能する", :js do
        visit mypage_techniques_path(locale: I18n.locale)
        submission = I18n.t("enums.category.submission")
        control = I18n.t("enums.category.control")
        find(:css, %(input[type="checkbox"][aria-label="#{submission}"])).click

        # サブミットカテゴリーのテクニックのみが表示される
        expect(page).to have_content(submission)
        expect(page).not_to have_content(control)

        # リセットボタンを押すと、コントロールカテゴリーのテクニックも表示されるようになる
        find(:css, "input[type='reset']").click
        expect(page).to have_content(submission)
        expect(page).to have_content(control)
      end
    end
  end

  describe "newアクション" do
    it "新規作成フォームが表示される" do
      visit new_mypage_technique_path(locale: I18n.locale)
      expect(page).to have_field(I18n.t("helpers.label.technique_name"))
      expect(page).to have_field(I18n.t("helpers.label.note"))
      expect(page).to have_field(I18n.t("helpers.label.category"))
      expect(page).to have_button(I18n.t("helpers.submit.create"))
    end

    it "一覧ページへ戻るリンクが機能する" do
      visit new_mypage_technique_path(locale: I18n.locale)
      click_link(I18n.t("defaults.back"))
      expect(page).to have_current_path(mypage_techniques_path(locale: I18n.locale))
    end
  end

  describe "editアクション" do
    before do
      user.techniques.create! do |t|
        t.set_name_for("test1")
      end
    end

    it "編集フォームが表示される" do
      visit mypage_techniques_path(locale: I18n.locale)
      expect(page).to have_css('a[data-turbo-frame="technique-drawer"]')
      find('a[data-turbo-frame="technique-drawer"]', match: :first).click
      expect(page).to have_field(I18n.t("helpers.label.technique_name"), with: "test1")
      expect(page).to have_field(I18n.t("helpers.label.note"))
      expect(page).to have_field(I18n.t("helpers.label.category"))
      expect(page).to have_button(I18n.t("helpers.submit.update"))
      expect(page).to have_link(I18n.t("defaults.delete"))
    end
  end

  describe "createアクション" do
    context "有効なデータの場合" do
      it "テクニックが作成できる" do
        visit new_mypage_technique_path(locale: I18n.locale)
        fill_in I18n.t("helpers.label.technique_name"), with: "test1"
        fill_in I18n.t("helpers.label.note"), with: "test note!"
        select I18n.t("enums.category.submission"), from: I18n.t("helpers.label.category")
        expect {
          click_button(I18n.t("helpers.submit.create"))
        }.to change(user.techniques, :count).by(1)
        expect(page).to have_current_path(mypage_techniques_path(locale: I18n.locale))
        expect(page).to have_content("test1")
        expect(page).to have_content("test note!")
        expect(page).to have_content(I18n.t("defaults.flash_messages.created", item: Technique.model_name.human))
      end
    end

    context "テクニック名が空の場合" do
      it "テクニックの作成に失敗する" do
        visit new_mypage_technique_path(locale: I18n.locale)
        fill_in I18n.t("helpers.label.note"), with: "test note!"
        select I18n.t("enums.category.submission"), from: I18n.t("helpers.label.category")
        expect {
          click_button(I18n.t("helpers.submit.create"))
        }.to change(user.techniques, :count).by(0)
        expect(page).to have_current_path(mypage_techniques_path(locale: I18n.locale))
        expect(page).to have_content(I18n.t("defaults.flash_messages.not_created", item: Technique.model_name.human))
        # #{Technique.human_attribute_name(:name_ja)} = I18n.t("activerecord.attributes.technique.name_ja")
        expect(page).to have_content("#{Technique.human_attribute_name(:name_ja)}#{I18n.t('errors.messages.blank')}")
      end
    end

    context "テクニック名が既存データと重複する場合" do
        let!(:technique) do
          user.techniques.create! do |t|
            t.set_name_for("test1")
          end
        end

      it "テクニックの作成に失敗する" do
        visit new_mypage_technique_path(locale: I18n.locale)
        fill_in I18n.t("helpers.label.technique_name"), with: "test1"
        fill_in I18n.t("helpers.label.note"), with: "test note!"
        select I18n.t("enums.category.submission"), from: I18n.t("helpers.label.category")
        expect {
          click_button(I18n.t("helpers.submit.create"))
        }.to change(user.techniques, :count).by(0)
        expect(page).to have_current_path(mypage_techniques_path(locale: I18n.locale))
        expect(page).to have_content(I18n.t("defaults.flash_messages.not_created", item: Technique.model_name.human))
        expect(page).to have_content("#{Technique.human_attribute_name(:name_ja)}#{I18n.t('errors.messages.taken')}")
      end
    end
  end

  describe "updateアクション" do
    before do
      user.techniques.create! do |t|
        t.set_name_for("test2")
      end

      # 後に作ったテクニックが find('a[data-turbo-frame="technique-drawer"]', match: :first).click にマッチする
      user.techniques.create! do |t|
        t.set_name_for("test1")
      end
    end

    context "有効なデータの場合" do
      it "テクニックが更新できる" do
        visit mypage_techniques_path(locale: I18n.locale)
        expect(page).to have_css('a[data-turbo-frame="technique-drawer"]')
        find('a[data-turbo-frame="technique-drawer"]', match: :first).click

        fill_in I18n.t("helpers.label.technique_name"), with: "retest3"
        fill_in I18n.t("helpers.label.note"), with: "retest note!3"
        select I18n.t("enums.category.submission"), from: I18n.t("helpers.label.category")
        click_button(I18n.t("helpers.submit.update"))

        expect(page).to have_current_path(mypage_techniques_path(locale: I18n.locale))
        expect(page).to have_content("retest3")
        expect(page).to have_content("retest note!3")
        expect(page).to have_content(I18n.t("defaults.flash_messages.updated", item: Technique.model_name.human))
      end
    end

    context "テクニック名が空の場合" do
      it "テクニックの更新に失敗する" do
        visit mypage_techniques_path(locale: I18n.locale)
        expect(page).to have_css('a[data-turbo-frame="technique-drawer"]')
        find('a[data-turbo-frame="technique-drawer"]', match: :first).click

        fill_in I18n.t("helpers.label.technique_name"), with: ""
        fill_in I18n.t("helpers.label.note"), with: "retest note!"
        select I18n.t("enums.category.submission"), from: I18n.t("helpers.label.category")
        click_button(I18n.t("helpers.submit.update"))

        expect(page).to have_current_path(mypage_techniques_path(locale: I18n.locale))
        expect(page).to have_content("test1")
        expect(page).to have_content("test2")
        expect(page).to have_content(I18n.t("defaults.flash_messages.not_updated", item: Technique.model_name.human))
        expect(page).to have_content("#{Technique.human_attribute_name(:name_ja)}#{I18n.t('errors.messages.blank')}")
      end
    end

    context "テクニック名が既存データと重複する場合" do
      it "テクニックの更新に失敗する" do
        visit mypage_techniques_path(locale: I18n.locale)
        expect(page).to have_css('a[data-turbo-frame="technique-drawer"]')
        find('a[data-turbo-frame="technique-drawer"]', match: :first).click

        fill_in I18n.t("helpers.label.technique_name"), with: "test2"
        fill_in I18n.t("helpers.label.note"), with: "retest note!"
        select I18n.t("enums.category.submission"), from: I18n.t("helpers.label.category")
        click_button(I18n.t("helpers.submit.update"))

        expect(page).to have_current_path(mypage_techniques_path(locale: I18n.locale))
        expect(page).to have_content("test1")
        expect(page).to have_content("test2")
        expect(page).to have_content(I18n.t("defaults.flash_messages.not_updated", item: Technique.model_name.human))
        expect(page).to have_content("#{Technique.human_attribute_name(:name_ja)}#{I18n.t('errors.messages.taken')}")
      end
    end
  end

  describe "destroyアクション" do
    before do
      user.techniques.create! do |t|
        t.set_name_for("test1")
      end
    end

    # モーダルが出てくるので要js
    it "テクニックを削除できる", :js do
      visit mypage_techniques_path(locale: I18n.locale)
      expect(page).to have_css('a[data-turbo-frame="technique-drawer"]')
      find('a[data-turbo-frame="technique-drawer"]', match: :first).click

      expect {
        accept_confirm(I18n.t("defaults.delete_confirm")) do
          click_link(I18n.t("defaults.delete"))
        end

        expect(page).to have_content(I18n.t("defaults.flash_messages.deleted", item: Technique.model_name.human))
      }.to change(user.techniques, :count).by(-1)

      expect(page).to have_current_path(mypage_techniques_path(locale: I18n.locale))
      expect(page).not_to have_content("test1")
    end
  end
end
