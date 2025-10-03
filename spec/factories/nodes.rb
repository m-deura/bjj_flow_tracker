FactoryBot.define do
  factory :node do
    association :chart
    association :technique
    ancestry { "/" }
  end
end
