require "csv"

# ラーメン店情報インポート
CSV.foreach('db/write-sample.csv', headers: true) do |row|
  RamenShop.create!(
    name: row['name'],
    address: row['address'],
  )
end

password = "password"
User.create!(name:  Faker::JapaneseMedia::StudioGhibli.character,
  email: "example@railstutorial.org",
  password:              password,
  password_confirmation: password,
  admin: true,
  activated: true,
  activated_at: Time.zone.now)

15.times do |n|
name  = Faker::JapaneseMedia::StudioGhibli.character
email = "example-#{n+1}@railstutorial.org"
User.create!(name:  name,
    email: email,
    password:              password,
    password_confirmation: password,
    activated: true,
    activated_at: Time.zone.now)
end

# ダミー着丼時間入稿
shops = RamenShop.all
counter = 0
users = User.all
shops.each do |shop|
  wait_times = []
  1.upto(15) { |num|
    started_at = Time.now - (60 * 60) - (num * 60) - (counter * 10)
    ended_at = Time.now + (num * 60) + (counter * 10)
    wait_time = Time.at(ended_at - started_at)

    wait_times << {
      started_at: started_at,
      ended_at: ended_at,
      wait_time: wait_time,
    }
  }

  user_num = 0
  wait_times.each do |time|
    shop.records.create!(
      started_at: time[:started_at],
      ended_at: time[:ended_at],
      wait_time: time[:wait_time],
      comment: 'ちゃくどん！',
      user: users[user_num],
      line_statuses_attributes: [
        {"line_number"=>10, "line_type"=>"outside_the_store", "comment"=>"長くなりそうだ", created_at: time[:started_at] },
        {"line_number"=>2, "line_type"=>"outside_the_store", "comment"=>"もうすぐ店内", created_at: time[:started_at] + 1800 },
        {"line_number"=>4, "line_type"=>"inside_the_store", "comment"=>"あと少し", created_at: time[:started_at] + 2400 },
        ]
    )
    user_num += 1
  end

  counter += 1
end
