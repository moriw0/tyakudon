FactoryBot.define do
  factory :user do
    name { 'Example User' }
    email { 'user@example.com' }
    password { 'foobar' }
    password_confirmation { 'foobar' }

    factory :other_user do
      name { 'Other User' }
      email { 'other@example.com' }
    end

    factory :all_user do
      sequence(:name) { |n| "tester#{n}" }
      sequence(:email) { |n| "tester#{n}@example.com" }
    end
  end
end
