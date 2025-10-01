FactoryBot.define do
  factory :chart_preset do
    sequence(:name) { |n| "chart_preset-#{n}" }
  end
end
