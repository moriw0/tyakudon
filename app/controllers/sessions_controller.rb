class SessionsController < ApplicationController
  include Authenticatable
  before_action :disable_connect_button, only: %i[new]

  def new
  end

  def create
    Sentry.capture_message('Session created') if Rails.env.production?

    if request.env['omniauth.auth'].present?
      oauth_authentication(request.env['omniauth.auth'])
    else
      standard_authentication
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path, status: :see_other, notice: 'ログアウトしました'
  end

  def failure
    redirect_to root_path, alert: 'ログインに失敗しました'
  end

  private

  def oauth_authentication(auth)
    user = User.find_by(provider: auth[:provider], uid: auth[:uid])

    if user
      handle_authentication(user, remember: true)
    else
      handle_new_oauth_user(auth)
    end
  end

  def handle_new_oauth_user(auth)
    existing_user = User.find_by(email: auth[:info][:email])

    if existing_user
      redirect_to login_path, notice: '既に登録されているメールアドレスです。ログインしてください。'
    else
      session['auth_data'] = auth.except('extra')
      redirect_to new_omniauth_user_path
    end
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
end
