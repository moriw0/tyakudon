module ApplicationHelper
  def format_datetime(datetime)
    return unless datetime

    wdays = %w[日 月 火 水 木 金 土]
    datetime.strftime("%Y/%m/%d(#{wdays[datetime.wday]}) %H:%M")
  end

  def format_datetime_detail(datetime)
    return unless datetime

    wdays = %w[日 月 火 水 木 金 土]
    datetime.strftime("%Y.%m.%d(#{wdays[datetime.wday]}) %H:%M:%S")
  end

  def format_only_detatil_time(datetime)
    return unless datetime

    datetime.strftime('%H:%M:%S')
  end

  # rubocop:disable Metrics/MethodLength
  def format_wait_time(wait_time)
    return unless wait_time

    hours, remainder = wait_time.divmod(3600)
    minutes, remainder_seconds = remainder.divmod(60)
    seconds, milliseconds = remainder_seconds.divmod(1)
    milliseconds = (milliseconds * 1000).round

    formatted_time = format('%<hours>02d:%<minutes>02d:%<seconds>02d',
                            hours: hours,
                            minutes: minutes,
                            seconds: seconds)
    formatted_milliseconds = format('.%<milliseconds>03d', milliseconds: milliseconds)

    tag.span(formatted_time, class: 'hh-mm-ss') + tag.span(formatted_milliseconds, class: 'small-milliseconds')
  end
  # rubocop:enable Metrics/MethodLength

  def turbo_stream_flash
    turbo_stream.update 'flash', partial: 'flash'
  end

  # rubocop:disable Rails/HelperInstanceVariable
  def show_connect_button?
    defined?(@show_connect_button) ? @show_connect_button : true
  end
  # rubocop:enable Rails/HelperInstanceVariable

  def skeleton_background_tag(class_name)
    tag.div class: [class_name, 'skeleton'], data: { controller: 'image', image_target: 'skeleton' } do
      yield if block_given?
    end
  end

  def lazy_image_tag(image)
    image_tag image, loding: 'lazy', data: { image_target: 'image' }
  end
end
