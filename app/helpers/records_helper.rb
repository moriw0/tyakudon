module RecordsHelper
  ALLOWED_BACK_SOURCES = {
    'new_records' => :new_records_path,
    'ramen_shops' => :ramen_shops_path,
    'favorite_records' => :favorite_records_path
  }.freeze

  def back_path_for(source, ramen_shop)
    route_name = ALLOWED_BACK_SOURCES[source]
    return ramen_shop_path(ramen_shop) unless route_name

    send(route_name)
  end

  def shop_or_user(record, name)
    record.send(name).name
  end

  def remember_record?
    cookies[:record_id]
  end

  def fetch_record_id
    cookies.encrypted[:record_id]
  end

  BASE_URL = 'http://twitter.com/intent/tweet?'.freeze
  def generate_tweet_url(record, current_url)
    text = "#{record.ramen_shop.name}\n#{format_to_hms record.wait_time}でちゃくどん！"
    query = URI.encode_www_form(url: current_url, text: text, hashtags: 'ちゃくどん')
    BASE_URL + query
  end

  def format_to_hms(wait_time)
    return unless wait_time

    hours, remainder = wait_time.divmod(3600)
    minutes, seconds = remainder.divmod(60)

    format('%<hours>02d：%<minutes>02d：%<seconds>02d',
           hours: hours,
           minutes: minutes,
           seconds: seconds)
  end
end
