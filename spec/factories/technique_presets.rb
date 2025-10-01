FactoryBot.define do
  factory :technique_preset do
    sequence(:name_ja) { |n| "プリセット技#{n}" }
    sequence(:name_en) { |n| "Preset Technique#{n}" }
    category { :submission }
  end
end
