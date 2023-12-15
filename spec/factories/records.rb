FactoryBot.define do
  factory :record do
    started_at { Time.zone.now }
    ended_at { 10.minutes.from_now }
    wait_time { 600 }
    comment { 'いただきます！' }
    is_retired { false }
    auto_retired { false }
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
      sequence(:started_at) { |n| n.minute.from_now }
      sequence(:ended_at) { |n| (n + 10).minutes.from_now }
      sequence(:created_at) { |n| n.minute.from_now }
    end

    factory :record_only_has_started_at do
      ended_at { nil }
      wait_time { nil }
      comment { nil }
    end
  end
end
