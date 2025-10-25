FactoryBot.define do
  factory :edge do
    transient do
      chart { build(:chart) }  # 同じチャートを共有させる
    end

    from { association(:node, chart: chart) }
    to { association(:node, chart: chart) }
    flow { 1 }
  end
end
