records = Record.all

line_statuses = []
id = 0

records.each do |record|
  started_at = record[:started_at]
  ended_at = record[:ended_at]

  line_statuses += [
    {
      id: id + 1,
      record: record,
      line_number: 10,
      line_type: "outside_the_store",
      comment: "長くなりそうだ",
      created_at: started_at
    },
    {
      id: id + 2,
      record: record,
      line_number: 2,
      line_type: "outside_the_store",
      comment: "もうすぐ店内",
      created_at: started_at + (ended_at - started_at) / 2
    },
    {
      id: id + 3,
      record: record,
      line_number: 2,
      line_type: "inside_the_store",
      comment: "あと少し",
      created_at: ended_at
    }
  ]

  id += 3
end

LineStatus.seed(:id, line_statuses)
