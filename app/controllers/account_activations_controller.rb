class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      redirect_to user, notice: 'アカウントが有効化されました'
    else
      redirect_to root_path, alert: '無効な有効化リンクです'
    end
  end
end
