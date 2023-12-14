users = User.all
records = Record.all

likes = []

users.each do |user|
  liked_records = records.sample(100)

  liked_records.each do |record|
    likes << { user_id: user.id, record_id: record.id }
  end
end

Like.seed(:user_id, :record_id, *likes)
