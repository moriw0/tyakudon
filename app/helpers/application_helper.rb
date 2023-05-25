module ApplicationHelper
  def format_datetime(datetime)
    wdays = %w(日 月 火 水 木 金 土)
    datetime.strftime("%Y/%m/%d(#{wdays[datetime.wday]}) %H:%M")
  end

  def format_wait_time(wait_time)
    hours, remainder = wait_time.divmod(3600)
    minutes, seconds = remainder.divmod(60)
    format("%02d:%02d:%02d", hours, minutes, seconds)
  end
end
