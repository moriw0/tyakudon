module FormatSupport
  module System
    def format_wait_time_helper(wait_time)
      return unless wait_time

      hours, remainder = wait_time.divmod(3600)
      minutes, remainder_seconds = remainder.divmod(60)
      seconds, milliseconds = remainder_seconds.divmod(1)
      milliseconds = (milliseconds * 1000).round

      format('%<hours>02d:%<minutes>02d:%<seconds>02d.%<milliseconds>03d',
             hours: hours,
             minutes: minutes,
             seconds: seconds,
             milliseconds: milliseconds)
    end
  end
end

RSpec.configure do |config|
  config.include FormatSupport::System, type: :system
end
