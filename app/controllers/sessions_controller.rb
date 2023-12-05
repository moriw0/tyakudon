class SessionsController < ApplicationController
  before_action :disable_connect_button, only: %i[new]

  def new
  end

  def create
    if request.env['omniauth.auth'].present?
      oauth_authentication
    else
      standard_authentication
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path, status: :see_other, notice: 'ログアウトしました'
  end

  private

  def oauth_authentication
    user = User.find_or_create_from_auth!(request.env['omniauth.auth'])
    user.activate if user.activated == false
    handle_authentication(user, remember: true)
  end

  def standard_authentication
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      handle_successful_authentication(user)
    else
      handle_failed_authentication
    end
  end

  def handle_successful_authentication(user)
    remember_me = params[:session][:remember_me] == '1'
    handle_authentication(user, remember: remember_me)
  end

  def handle_failed_authentication
    flash.now.alert = 'ログインに失敗しました'
    render 'new', status: :unprocessable_entity
  end

  def handle_authentication(user, remember:)
    forwarding_url = session[:forwarding_url]
    reset_session
    remember ? remember(user) : forget(user)
    log_in user
    redirect_to forwarding_url || user, notice: 'ログインしました'
  end
end
