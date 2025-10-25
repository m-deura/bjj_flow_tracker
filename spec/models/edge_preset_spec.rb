require 'rails_helper'

RSpec.describe EdgePreset, type: :model do
  describe "バリデーション" do
    it "必須項目が揃っていれば有効" do
      ep = build(:edge_preset)
      expect(ep).to be_valid
      expect(ep.errors).to be_empty
    end
  end

  describe "リレーション" do
    it "from が必須" do
      ep = build(:edge_preset, from: nil)
      expect(ep).to be_invalid
      expect(ep.errors).to be_of_kind(:from, :blank)
    end

    it "to が必須" do
      ep = build(:edge_preset, to: nil)
      expect(ep).to be_invalid
      expect(ep.errors).to be_of_kind(:to, :blank)
    end
  end
end
