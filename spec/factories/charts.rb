FactoryBot.define do
  factory :chart do
    association :user
    sequence(:name) { |n| "chart-#{n}" }
  end
end
