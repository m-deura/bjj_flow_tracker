require 'rails_helper'

RSpec.describe Edge, type: :model do
  describe "バリデーション" do
    it "必須項目が揃っていれば有効" do
      e = build(:edge)
      expect(e).to be_valid
      expect(e.errors).to be_empty
    end
  end

  describe "リレーション" do
    it "from が必須" do
      e = build(:edge, from: nil)
      expect(e).to be_invalid
      expect(e.errors).to be_of_kind(:from, :blank)
    end

    it "to が必須" do
      e = build(:edge, to: nil)
      expect(e).to be_invalid
      expect(e.errors).to be_of_kind(:to, :blank)
    end

    it "flow が必須" do
      e = build(:edge, flow: nil)
      expect(e).to be_invalid
      expect(e.errors).to be_of_kind(:flow, :blank)
    end
  end
end
