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
