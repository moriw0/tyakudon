module RecordsHelper
  def shop_or_user(record, name)
    record.send(name).name
  end

  def remember_record?
    cookies[:record_id]
  end

  def fetch_record_id
    cookies.encrypted[:record_id]
  end
end
