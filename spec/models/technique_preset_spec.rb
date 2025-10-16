require 'rails_helper'

RSpec.describe TechniquePreset, type: :model do
  describe "バリデーション" do
    it "必須項目が揃っていれば有効" do
      tp = create(:technique_preset, name_ja: "テスト1", name_en: "test1", category: :control)
      expect(tp).to be_valid
      expect(tp.errors).to be_empty
    end

    it "name_ja が空だと無効" do
      tp = build(:technique_preset, name_ja: "", name_en: "test1")
      expect(tp).to be_invalid
      expect(tp.errors).to be_of_kind(:name_ja, :blank)
    end

    it "name_en が空だと無効" do
      tp = build(:technique_preset, name_ja: "テスト1", name_en: "")
      expect(tp).to be_invalid
      expect(tp.errors).to be_of_kind(:name_en, :blank)
    end

    it "name_ja は一意" do
      create(:technique_preset, name_ja: "重複", name_en: "test1")
      dup = build(:technique_preset, name_ja: "重複", name_en: "test2")

      expect(dup).to be_invalid
      expect(dup.errors).to be_of_kind(:name_ja, :taken)
    end

    it "name_en は一意" do
      create(:technique_preset, name_ja: "テスト1", name_en: "dup")
      dup = build(:technique_preset, name_ja: "テスト2", name_en: "dup")

      expect(dup).to be_invalid
      expect(dup.errors).to be_of_kind(:name_en, :taken)
    end

    it "category は空でも有効" do
      tp = create(:technique_preset, name_ja: "テスト1", name_en: "test1", category: nil)
      expect(tp).to be_valid
        expect(tp.errors).to be_empty
    end
  end

  describe "リレーション" do
    it "関連テクニックがある場合は削除できない" do
      tp = create(:technique_preset)
      create(:technique, name_ja: "テスト1", name_en: "test1", technique_preset: tp)

      expect {
        tp.destroy
      }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end

    it "削除時に関連プリセットノードが消える" do
      tp = create(:technique_preset)
      create_list(:node_preset, 2, technique_preset: tp)

      expect {
        tp.destroy
      }.to change { NodePreset.where(technique_preset_id: tp.id).count }.from(2).to(0)
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
end
