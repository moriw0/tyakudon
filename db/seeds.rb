require "csv"

# ラーメン店情報インポート
CSV.foreach('db/write-sample.csv', headers: true) do |row|
  RamenShop.create(
    name: row['name'],
    address: row['address'],
  )
end

# ダミー着丼時間入稿
shops = RamenShop.all.limit(10)
counter = 0
shops.each do |shop|
  elapsed_times = []
  1.upto(10) { |num|
    started_at = Time.now - (60 * 60) - (num * 60) - (counter * 10)
    ended_at = Time.now + (num * 60) + (counter * 10)
    elapsed_time = Time.at(ended_at - started_at)
    
    elapsed_times << {
      started_at: started_at,
      ended_at: ended_at,
      elapsed_time: elapsed_time
    }
  }

  elapsed_times.each do |time|
    shop.records.create(
      started_at: time[:started_at],
      ended_at: time[:ended_at],
      elapsed_time: time[:elapsed_time]
    )
  end

  counter += 1
end
