require "csv"

CSV.foreach('db/write-sample.csv', headers: true) do |row|
  RamenShop.create(
    name: row['name'],
    address: row['address'],
  )
end
