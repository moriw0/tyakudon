module Authenticatable
  extend ActiveSupport::Concern

  private

  def handle_authentication(user, remember:)
    forwarding_url = session[:forwarding_url]
    reset_session
    remember ? remember(user) : forget(user)
    log_in user
    redirect_to forwarding_url || root_path, notice: 'ログインしました'
  end
end
