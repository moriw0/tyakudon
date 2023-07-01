class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      reset_session
      remember user
      log_in user
      redirect_to user, notice: 'ログインしました'
    else
      flash.now.alert = 'ログインに失敗しました'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path, status: :see_other, notice: 'ログアウトしました'
  end
end
