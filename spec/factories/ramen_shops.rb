FactoryBot.define do
  factory :ramen_shop do
    name { '家系らーめん 武将家 外伝' }
    address { '〒101-0023 東京都千代田区神田松永町16' }
    latitude { 35.7000396 }
    longitude { 139.7752222 }

    factory :many_shops do
      sequence(:name) { |n| "#{n}号ラーメン店" }
    end
  end
end
