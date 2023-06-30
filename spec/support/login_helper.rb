module LoginSupport
  def is_logged_in?
    !session[:user_id].nil?
  end
end

RSpec.configure do |config|
  config.include LoginSupport
end
