FactoryBot.define do
  factory :user do
    name { 'Example User' }
    email { 'user@example.com' }
    password { 'foobar' }
    password_confirmation { 'foobar' }
    admin { false }
    activated { true }
    activated_at { Time.zone.now }
    is_test_mode { false }

    trait :other_user do
      name { 'Other User' }
      email { 'other@example.com' }
    end

    trait :admin do
      name { 'Admin User' }
      email { 'admin@example.com' };
      admin { true }
    end

    trait :not_activated do
      name { 'Non Activated User' }
      email { 'not_activated@example.com' }
      activated { false }
      activated_at { nil }
    end

    trait :many_user do
      sequence(:name) { |n| "tester#{n}" }
      sequence(:email) { |n| "tester#{n}@example.com" }
    end
  end
end
