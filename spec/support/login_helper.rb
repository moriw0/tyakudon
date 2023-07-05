module LoginSupport
  module System
    def log_in_as(user)
      visit login_path

      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: user.password
      click_button 'ログインする'
    end
  end

  module Request
    def is_logged_in?
      !session[:user_id].nil?
    end

    def log_in_as(user, password: user.password, remember_me: '1')
      post login_path, params: { session: { email: user.email,
                                            password: password,
                                            remember_me: remember_me } }
    end
  end
end

RSpec.configure do |config|
  config.include LoginSupport::System, type: :system
  config.include LoginSupport::Request, type: :request
  config.include LoginSupport::Request, type: :helper
end
