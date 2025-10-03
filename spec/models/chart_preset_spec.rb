require 'rails_helper'

RSpec.describe ChartPreset, type: :model do
  describe "バリデーション" do
    it "必須項目が揃っていれば有効" do
      tp = create(:chart_preset)
      expect(tp).to be_valid
      expect(tp.errors).to be_empty
    end

    it "name が空だと無効" do
      tp = build(:chart_preset, name: "")
      expect(tp).to be_invalid
      expect(tp.errors).to be_of_kind(:name, :blank)
    end

    it "name は一意" do
      dup_name = "test1"
      create(:chart_preset, name: dup_name)
      dup = build(:chart_preset, name: dup_name)

      expect(dup).to be_invalid
      expect(dup.errors).to be_of_kind(:name, :taken)
    end
  end

  describe "リレーション" do
    it "関連チャートがある場合は削除できない" do
      cp = create(:chart_preset)
      create_list(:chart, 2, chart_preset: cp)

      expect {
        cp.destroy
      }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end

    it "削除時に関連プリセットノードが消える" do
      cp = create(:chart_preset)
      create_list(:node_preset, 2, chart_preset: cp)

      expect {
        cp.destroy
      }.to change { NodePreset.where(chart_preset_id: cp.id).count }.from(2).to(0)
    end
  end
end
