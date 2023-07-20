module RecordsHelper
  def shop_or_user(record, name)
    record.send(name).name
  end

  def remember_record
  end

  def forget_record
  end
end
