require 'rails_helper'

RSpec.describe Transition, type: :model do
  describe "バリデーション" do
    it "必須項目が揃っていれば有効" do
      tr = build(:transition)
      expect(tr).to be_valid
      expect(tr.errors).to be_empty
    end
  end

  describe "リレーション" do
    it "from が必須" do
      tr = build(:transition, from: nil)
      expect(tr).to be_invalid
      expect(tr.errors).to be_of_kind(:from, :blank)
    end

    it "to が必須" do
      tr = build(:transition, to: nil)
      expect(tr).to be_invalid
      expect(tr.errors).to be_of_kind(:to, :blank)
    end
  end
end
