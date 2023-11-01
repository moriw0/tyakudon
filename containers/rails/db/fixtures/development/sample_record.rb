users = User.all

wait_times = (1..15).map do |n|
  started_at = (n * rand(2..15)).minutes.ago
  ended_at = n.minutes.ago

  {
    started_at: started_at,
    ended_at: ended_at,
    wait_time: Time.at(ended_at - started_at),
    created_at: ended_at
  }
end

shops = RamenShop.take(15)

id = 0
records = []
shops.each do |shop|
  wait_times.each_with_index do |time, index|
    id += 1

    records << {
      id: id,
      user: users[rand(0..14)],
      ramen_shop: shop,
      started_at: time[:started_at],
      ended_at: time[:ended_at],
      wait_time: time[:wait_time],
      comment: 'ちゃくどん！',
    }
  end
end

Record.seed(:id, records)
