module ApplicationHelper
  def format_datetime(datetime)
    return unless datetime

    wdays = %w[日 月 火 水 木 金 土]
    datetime.strftime("%Y/%m/%d(#{wdays[datetime.wday]}) %H:%M")
  end

  def format_datetime_detail(datetime)
    return unless datetime

    wdays = %w[日 月 火 水 木 金 土]
    datetime.strftime("%Y/%m/%d(#{wdays[datetime.wday]}) %H:%M:%S")
  end

  def format_only_detatil_time(datetime)
    return unless datetime

    datetime.strftime('%H:%M:%S')
  end

  def format_wait_time_human(wait_time)
    return unless wait_time

    hours, remainder = wait_time.divmod(3600)
    minutes, seconds = remainder.divmod(60)
    seconds = seconds.round

    parts = []
    parts << "#{hours}時間" if hours.positive?
    parts << "#{minutes}分" if minutes.positive?
    parts << "#{seconds}秒" if seconds.positive? || parts.empty?
    parts.join
  end

  # rubocop:disable Metrics/MethodLength
  def wait_time_tag(wait_time)
    return tag.span('接続中...', class: 'connecting-label') unless wait_time

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

  def format_near_distance(distance_in_miles)
    meters = (distance_in_miles * 1609.344).round
    meters >= 1000 ? "#{format('%.1f', meters / 1000.0)}km" : "#{meters}m"
  end

  def near_shop_wait_time(shop)
    record = shop.last_active_record
    return '記録なし' unless record&.wait_time

    "#{format_wait_time_human(record.wait_time)}（#{format_only_detatil_time(record.ended_at)}）"
  end

  # rubocop:disable Rails/HelperInstanceVariable
  def toggle_ui_path(enable_v2:)
    query = request.query_parameters.except('v2').merge('v2' => enable_v2 ? '1' : '0')
    "#{request.path}?#{query.to_query}"
  end

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

  # rubocop:disable Metrics/MethodLength
  def default_meta_tags
    {
      site: 'ちゃくどん',
      title: 'ラーメン待ち時間計測・共有Webアプリ',
      reverse: true,
      icon: [
        { href: image_url('favicon.ico') },
        { href: image_url('favicon.ico'), rel: 'apple-touch-icon', sizes: '180x180', type: 'image/jpg' }
      ],
      charset: 'utf-8',
      description: '行列に並ぶ「接続」から、ラーメンが提供される「着丼」までの時間を計測して共有しよう',
      keywords: 'ラーメン, 着丼, 行列',
      canonical: request.original_url,
      separator: '|',
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: 'website',
        url: request.original_url,
        image: image_url('ogp.png'),
        locale: 'ja-JP'
      },
      twitter: {
        card: 'summary_large_image',
        site: '@tonka2w0',
        image: image_url('ogp.png')
      }
    }
  end
  # rubocop:enable Metrics/MethodLength
end
