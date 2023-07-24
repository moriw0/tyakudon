module ApplicationHelper
  def format_datetime(datetime)
    return unless datetime

    wdays = %w[日 月 火 水 木 金 土]
    datetime.strftime("%Y/%m/%d(#{wdays[datetime.wday]}) %H:%M")
  end

  def format_wait_time(wait_time)
    return unless wait_time

    hours, remainder = wait_time.divmod(3600)
    minutes, seconds = remainder.divmod(60)
    format('%<hours>02d:%<minutes>02d:%<seconds>02d', hours: hours, minutes: minutes, seconds: seconds)
  end

  def turbo_stream_flash
    turbo_stream.update 'flash', partial: 'flash'
  end

  # rubocop:disable Rails/HelperInstanceVariable
  def show_connect_button?
    defined?(@show_connect_button) ? @show_connect_button : true
  end
  # rubocop:enable Rails/HelperInstanceVariable
end
