FactoryBot.define do
  factory :record do
    started_at { 11.minutes.ago }
    ended_at { 1.minute.ago }
    wait_time { 600 }
    comment { 'いただきます！' }
    ramen_shop
  end
end
