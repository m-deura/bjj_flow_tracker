FactoryBot.define do
  factory :user do
    provider { "google_oauth2" }
    sequence(:uid)   { |n| "uid-#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name)  { |n| "Test User#{n}" }
    password { "password" }
    image { "https://example.com/avatar.png" }
  end
end
