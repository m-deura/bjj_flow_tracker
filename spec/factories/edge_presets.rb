FactoryBot.define do
  factory :edge_preset do
    transient do
      chart_preset { build(:chart_preset) }  # 同じチャートを共有させる
    end

    from { create(:node_preset, chart_preset: chart_preset) }
    to { create(:node_preset, chart_preset: chart_preset) }
  end
end
