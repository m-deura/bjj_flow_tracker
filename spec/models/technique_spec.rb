require 'rails_helper'

RSpec.describe Technique, type: :model do
  let(:user) { create(:user) }

  describe "関連" do
    it "ユーザーに必須で属する" do
      t = build(:technique, user: nil, name_ja: "テスト1", name_en: "test1")
      expect(t).to be_invalid
      expect(t.errors).to be_of_kind(:user, :blank)
    end

    it "technique_preset は任意" do
      t = build(:technique, :no_preset, user:)
      expect(t).to be_valid
      expect(t.errors).to be_empty
    end

    it "削除時に関連ノードが消える" do
      technique = create(:technique, user:)
      create_list(:node, 2, technique:)
      expect { technique.destroy }.to change { Node.where(technique_id: technique.id).count }.from(2).to(0)
    end
  end

  describe "バリデーション" do
    it "name_ja と name_en の双方が空だと無効" do
      t = build(:technique, user:, name_ja: "", name_en: "")
      expect(t).to be_invalid
      # 両方が blank の場合、name_en のバリデーションチェックはスキップされる
      expect(t.errors).to be_of_kind(:name_ja, :blank)
      expect(t.errors[:name_en]).to be_empty
    end

    it "name_ja は user 単位で一意" do
      create(:technique, user:, name_ja: "テスト1", name_en: "test1")
      dup = build(:technique, user:, name_ja: "テスト1", name_en: "another test1")
      expect(dup).to be_invalid
      expect(dup.errors).to be_of_kind(:name_ja, :taken)
    end

    it "name_en は user 単位で大文字小文字を無視して一意" do
      create(:technique, user:, name_ja: "テスト1", name_en: "Guillotine")
      dup = build(:technique, user:, name_ja: "別テスト1", name_en: "gUiLlOtInE")
      expect(dup).to be_invalid
      expect(dup.errors).to be_of_kind(:name_en, :taken)
    end

    it "name_en と name_ja が同値のとき、name_en 側のユニーク検証はスキップ（重複エラー二重表示防止）" do
      create(:technique, user:, name_ja: "test1", name_en: "test1")
      dup = build(:technique, user:, name_ja: "test1", name_en: "test1")
      expect(dup).to be_invalid
      # name_ja 側にはエラーが出るが、name_en 側はスキップされる想定
      expect(dup.errors).to be_of_kind(:name_ja, :taken)
      expect(dup.errors[:name_en]).to be_blank
    end

    it "別ユーザーならテクニック名が重複しても有効" do
      other_user = create(:user)
      create(:technique, user:, name_ja: "テスト1", name_en: "test1")
      dup = build(:technique, user: other_user, name_ja: "テスト1", name_en: "test1")
      expect(dup).to be_valid
    end
  end

  describe "enum :category" do
    it "定義されたキーを受け付ける" do
      %i[submission sweep pass guard control takedown].each do |key|
        tp = build(:technique_preset, name_ja: "ja-#{key}", name_en: "en-#{key}", category: key)
        expect(tp).to be_valid
        expect(tp.errors).to be_empty
      end
    end

    it "不正なカテゴリーは受け付けない" do
      expect {
        create(:technique_preset, name_ja: "不正", name_en: "Invalid", category: :unknown)
      }.to raise_error(ArgumentError)
    end
  end

  describe "ransack" do
    it ".ransackable_associations は user のみ" do
      expect(Technique.ransackable_associations).to eq([ "user" ])
    end

    it ".ransackable_attributes は name_ja/name_en/note" do
      expect(Technique.ransackable_attributes).to match_array(%w[name_ja name_en note])
    end
  end

  describe ".name_field_for" do
    around do |ex|
      orig = I18n.locale # 今のロケールを保存
      ex.run # ここでitブロックを実行
      I18n.locale = orig # 後処理でロケールを元に戻す
    end

    it "ja のとき :name_ja を返す" do
      I18n.locale = :ja
      expect(Technique.name_field_for).to eq :name_ja
    end

    it "en のとき :name_en を返す" do
      I18n.locale = :en
      expect(Technique.name_field_for).to eq :name_en
    end

    it "未知ロケールのときは default_locale(:ja) へフォールバック" do
      expect(Technique.name_field_for(:xx)).to eq :name_ja
    end
  end

  describe "#name_for" do
    let(:technique) { build(:technique, user:, name_ja: "テスト1", name_en: "test1") }

    it "ja では name_ja" do
      expect(technique.name_for(:ja)).to eq "テスト1"
    end

    it "en では name_en" do
      expect(technique.name_for(:en)).to eq "test1"
    end

    it "presence ベースで返す（空なら nil を返す）" do
      technique.name_en = ""
      expect(technique.name_for(:en)).to be_nil
    end
  end

  describe "#set_name_for" do
    context "プリセット由来ではないとき(secondary も更新される)" do
      let(:technique) { create(:technique, :no_preset, user:, name_ja: "テスト1", name_en: "test1") }

      it "loc=ja で両方更新して保存する" do
        expect(technique.set_name_for("リテスト2", :ja)).to be true
        technique.reload
        expect(technique.name_ja).to eq "リテスト2"
        expect(technique.name_en).to eq "リテスト2"
      end

      it "loc=en で両方更新して保存する" do
        expect(technique.set_name_for("retest2", :en)).to be true
        technique.reload
        expect(technique.name_en).to eq "retest2"
        expect(technique.name_ja).to eq "retest2"
      end
    end

    context "プリセット由来のとき(secondary は更新しない)" do
      let(:preset)    { create(:technique_preset) }
      let(:technique) { create(:technique, user:, technique_preset: preset, name_ja: "テスト1", name_en: "test1") }

      it "loc=ja で name_ja のみ更新" do
        expect(technique.set_name_for("リテスト2", :ja)).to be true
        technique.reload
        expect(technique.name_ja).to eq "リテスト2"
        expect(technique.name_en).to eq "test1"
      end

      it "loc=en で name_en のみ更新" do
        expect(technique.set_name_for("retest2", :en)).to be true
        technique.reload
        expect(technique.name_en).to eq "retest2"
        expect(technique.name_ja).to eq "テスト1"
      end
    end
  end

  describe "callbacks" do
    it "populate_missing_name: name_en のみ与えたら name_ja を補完" do
      t = create(:technique, :no_preset, user:, name_ja: "", name_en: "test1")
      expect(t.name_ja).to eq "test1"
    end

    it "populate_missing_name: name_ja のみ与えたら name_en を補完" do
      t = create(:technique, :no_preset, user:, name_ja: "テスト1", name_en: "")
      expect(t.name_en).to eq "テスト1"
    end
  end
end
