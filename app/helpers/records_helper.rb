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

  def format_datetime_detail(datetime)
    return unless datetime

    wdays = %w[日 月 火 水 木 金 土]
    datetime.strftime("%Y.%m.%d(#{wdays[datetime.wday]}) %H:%M:%S")
  end

  def format_only_detatil_time(datetime)
    return unless datetime

    datetime.strftime("%H:%M:%S")
  end
end
