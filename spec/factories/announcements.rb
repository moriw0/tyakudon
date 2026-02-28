FactoryBot.define do
  factory :announcement do
    sequence(:title) { |n| "お知らせ#{n}" }
    published_at { 1.hour.ago }

    trait :draft do
      published_at { 1.hour.from_now }
    end
  end
end
