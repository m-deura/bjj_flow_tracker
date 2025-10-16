require 'rails_helper'

RSpec.describe Node, type: :model do
  describe "バリデーション" do
    it "必須項目が揃っていれば有効" do
      t = build(:node)
      expect(t).to be_valid
      expect(t.errors).to be_empty
    end
  end

  describe "リレーション" do
    it "chart が必須" do
      t = build(:node, chart: nil)
      expect(t).to be_invalid
      expect(t.errors).to be_of_kind(:chart, :blank)
    end

    it "technique が必須" do
      t = build(:node, technique: nil)
      expect(t).to be_invalid
      expect(t.errors).to be_of_kind(:technique, :blank)
    end
  end
end
