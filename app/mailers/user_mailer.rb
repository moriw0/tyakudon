class UserMailer < ApplicationMailer
  def account_activation(user)
    @user = user
    mail to: user.email, subject: 'アカウントの有効化に関して'
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: 'パスワードリセットについて'
  end
end
