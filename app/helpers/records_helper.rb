module RecordsHelper
  def shop_or_user(record, name)
    record.send(name).name
  end
end
