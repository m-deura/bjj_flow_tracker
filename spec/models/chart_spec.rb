require 'rails_helper'

RSpec.describe Chart, type: :model do
  let(:user) { create(:user) }

  describe "バリデーション" do
    it "必須項目が揃っていれば有効" do
      c = build(:chart)
      expect(c).to be_valid
      expect(c.errors).to be_empty
    end

    it "name が空だと無効" do
      t = build(:chart, user:, name: "")
      expect(t).to be_invalid
      expect(t.errors).to be_of_kind(:name, :blank)
    end

    it "name は user 単位で一意" do
      dup_name = "test1"
      create(:chart, user:, name: dup_name)
      dup = build(:chart, user:, name: dup_name)
      expect(dup).to be_invalid
      expect(dup.errors).to be_of_kind(:name, :taken)
    end

    it "別ユーザーなら name が重複しても有効" do
      other_user = create(:user)
      dup_name = "test1"
      create(:chart, user:, name: dup_name)
      dup = build(:chart, user: other_user, name: dup_name)
      expect(dup).to be_valid
      expect(dup.errors).to be_empty
    end
  end

  describe "リレーション" do
    it "user が必須" do
      c = build(:chart, user: nil, name: "test1")
      expect(c).to be_invalid
      expect(c.errors).to be_of_kind(:user, :blank)
    end

    it "chart_preset は任意" do
      c = build(:chart, chart_preset: nil, user:, name: "test1")
      expect(c).to be_valid
      expect(c.errors).to be_empty
    end

    it "削除時に関連ノードが消える" do
      c = create(:chart, user:)
      create_list(:node, 2, chart: c)
      expect { c.destroy }.to change { Node.where(chart_id: c.id).count }.from(2).to(0)
    end
  end
end
