FactoryBot.define do
  factory :record do
    started_at { 11.minute.ago }
    ended_at { 1.minute.ago }
    wait_time { 600 }
    comment { 'いただきます！' }
    association :ramen_shop
  end
end
