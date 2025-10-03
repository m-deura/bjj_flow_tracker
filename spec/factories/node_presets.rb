FactoryBot.define do
  factory :node_preset do
    association :chart_preset
    association :technique_preset
    ancestry { "/" }
  end
end
