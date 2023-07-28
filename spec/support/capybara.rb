Webdrivers::Chromedriver.required_version = '114.0.5735.90'

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, js: true, type: :system) do
    driven_by :selenium_chrome
  end
end
