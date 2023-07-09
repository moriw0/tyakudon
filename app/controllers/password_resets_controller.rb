class PasswordResetsController < ApplicationController
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
end
