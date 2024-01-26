FactoryBot.define do
  factory :shop_register_request do
    name { '新ラーメン店' }
    address { '東京都新宿' }
    remarks { 'ぜひ登録お願いします' }
    status { 'open' }
    user
  end
end
