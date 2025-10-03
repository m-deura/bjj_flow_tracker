require 'rails_helper'

RSpec.describe NodePreset, type: :model do
  describe "バリデーション" do
    it "必須項目が揃っていれば有効" do
      t = build(:node_preset)
      expect(t).to be_valid
      expect(t.errors).to be_empty
    end
  end

  describe "リレーション" do
    it "chart_preset が必須" do
      t = build(:node_preset, chart_preset: nil)
      expect(t).to be_invalid
      expect(t.errors).to be_of_kind(:chart_preset, :blank)
    end

    it "technique_preset が必須" do
      t = build(:node_preset, technique_preset: nil)
      expect(t).to be_invalid
      expect(t.errors).to be_of_kind(:technique_preset, :blank)
    end
  end
end
