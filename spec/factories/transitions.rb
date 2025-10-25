FactoryBot.define do
  factory :transition do
    from { create(:technique) }
    to { create(:technique) }
  end
end
