module RamenShopsHelper
  def format_duration(duration)
    hours, remainder = duration.divmod(3600)
    minutes, seconds = remainder.divmod(60)
    format("%02d:%02d:%02d", hours, minutes, seconds)
  end
end
