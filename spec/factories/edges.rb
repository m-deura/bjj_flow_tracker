FactoryBot.define do
  factory :edge do
    transient do
      chart { build(:chart) }  # 同じチャートを共有させる
    end

    from { create(:node, chart: chart) }
    to { create(:node, chart: chart) }
    flow { 1 }
  end
end
