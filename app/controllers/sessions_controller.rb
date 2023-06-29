class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      reset_session
      log_in user
      redirect_to user, notice: 'ログインしました'
    else
      flash.now.alert = 'ログインに失敗しました'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
  end
end
