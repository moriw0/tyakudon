require 'socket'

Capybara.server_host = '0.0.0.0'
# Fixed port required for remote Selenium to connect back to the Capybara server.
Capybara.server_port = 3001

Capybara.register_driver :selenium_chrome_custom do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')

  if ENV['SELENIUM_REMOTE_URL'].present?
    Capybara::Selenium::Driver.new(
      app,
      browser: :remote,
      url: ENV['SELENIUM_REMOTE_URL'],
      options: options
    )
  else
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    Capybara.app_host = nil
    driven_by :rack_test
  end

  config.before(:each, js: true, type: :system) do
    if ENV['SELENIUM_REMOTE_URL'].present?
      ip = Socket.ip_address_list.detect(&:ipv4_private?)&.ip_address
      raise 'No private IPv4 address found. Cannot connect Selenium to the Capybara server.' unless ip

      Capybara.app_host = "http://#{ip}:#{Capybara.server_port}"
    end
    driven_by :selenium_chrome_custom
  end
end
