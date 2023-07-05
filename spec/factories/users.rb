FactoryBot.define do
  factory :user do
    name { 'Example User' }
    email { 'user@example.com' }
    password { 'foobar' }
    password_confirmation { 'foobar' }
    admin { true }
    activated { true }
    activated_at { Time.zone.now }

    factory :other_user do
      name { 'Other User' }
      email { 'other@example.com' }
      admin { false }
    end

    factory :all_user do
      sequence(:name) { |n| "tester#{n}" }
      sequence(:email) { |n| "tester#{n}@example.com" }
      admin { false }
    end
  end
end
