class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      redirect_to root_path, notice: 'メールを確認してパスワードを再設定してください'
    else
      flash.now.notice = 'アカウントが見つかりませんでした'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, 'を入力してください')
      render :edit, status: :unprocessable_entity
    elsif @user.update(user_params)
      reset_session
      forget @user
      @user.update_attribute(:reset_digest, nil)
      log_in @user
      redirect_to @user, notice: 'パスワードを更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    unless @user && @user.activated? &&
           @user.authenticated?(:reset, params[:id])
      redirect_to root_path, alert: '無効なユーザーによるリクエストです'
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      redirect_to new_password_reset_path, alert: 'パスワードリセット用URLの有効期限が切れています。'
    end
  end
end
