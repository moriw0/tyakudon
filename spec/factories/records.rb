FactoryBot.define do
  factory :record do
    started_at { 11.minutes.ago }
    ended_at { 1.minute.ago }
    wait_time { 600 }
    comment { 'いただきます！' }
    ramen_shop
    user

    factory :oldest do
      started_at { 1.year.ago - 10.minutes }
      ended_at { 1.year.ago }
      created_at { 1.year.ago }
    end

    factory :most_recent do
      started_at { 10.minutes.ago }
      ended_at { Time.zone.now }
      created_at { Time.zone.now }
    end

    factory :many_records do
      sequence(:started_at) { |n| (n + 10).minutes.ago }
      sequence(:ended_at) { |n| n.minutes.ago }
      sequence(:created_at) { |n| n.minutes.ago }
    end
  end
end
