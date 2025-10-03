FactoryBot.define do
  factory :chart do
    association :user
    association :chart_preset
    sequence(:name) { |n| "chart-#{n}" }
  end
end
