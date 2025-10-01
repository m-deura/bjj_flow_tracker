FactoryBot.define do
  factory :technique do
    association :user
    association :technique_preset, strategy: :build

    # Technique の必須項目を TechniquePreset に同期
    sequence(:name_ja) { |n| technique_preset&.name_ja || "技#{n}" }
    sequence(:name_en) { |n| technique_preset&.name_en || "Technique#{n}" }
    category { technique_preset&.category || :submission }
  end
end
