password = "password"

users = [
  {
    id: 1,
    name: Faker::JapaneseMedia::StudioGhibli.character,
    email: "example@railstutorial.org",
    password: password,
    password_confirmation: password,
    admin: true,
    activated: true,
    activated_at: Time.zone.now
  }
]

users += (2..15).map do |n|
  {
    id: n,
    name: Faker::JapaneseMedia::StudioGhibli.character,
    email: "example-#{n}@railstutorial.org",
    password: password,
    password_confirmation: password,
    admin: false,
    activated: true,
    activated_at: Time.zone.now,
  }
end

User.seed(:id, users)
