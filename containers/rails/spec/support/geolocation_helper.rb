module GeolocationHelper
  module System
    # rubocop:disable Metrics/MethodLength
    def mock_geolocation(lat, lon)
      script = <<-JS
        navigator.geolocation.getCurrentPosition = (success) => {
          var position = {
            coords: {
              latitude: #{lat},
              longitude: #{lon}
            }
          };
          success(position);
        };
      JS

      page.execute_script(script)
    end
    # rubocop:enable Metrics/MethodLength
  end
end

RSpec.configure do |config|
  config.include GeolocationHelper::System, type: :system
end
