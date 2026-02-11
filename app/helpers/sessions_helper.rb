module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
    session[:session_token] = user.session_token
  end

  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # rubocop:disable Rails/HelperInstanceVariable
  def current_user
    @current_user ||= begin
      if (user_id = session[:user_id])
        user = User.find_by(id: user_id)
        user if user && session[:session_token] == user.session_token
      elsif (user_id = cookies.encrypted[:user_id])
        user = User.find_by(id: user_id)
        if user&.authenticated?(:remember, cookies[:remember_token])
          log_in user
          user
        end
      end
    end
  end

  def current_user?(user)
    user && user == current_user
  end

  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_user)
    reset_session
    @current_user = nil
  end
  # rubocop:enable Rails/HelperInstanceVariable

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
