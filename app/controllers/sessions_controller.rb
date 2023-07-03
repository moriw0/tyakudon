class SessionsController < ApplicationController
  def new
  end

  # rubocop:disable Metrics/AbcSize
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      forwarding_url = session[:forwarding_url]
      reset_session
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      log_in user
      redirect_to forwarding_url || user, notice: 'ログインしました'
    else
      flash.now.alert = 'ログインに失敗しました'
      render 'new', status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize

  def destroy
    log_out if logged_in?
    redirect_to root_path, status: :see_other, notice: 'ログアウトしました'
  end
end
