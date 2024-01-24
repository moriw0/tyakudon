class UserMailer < ApplicationMailer
  helper ApplicationHelper

  def account_activation(user)
    @user = user
    mail to: user.email, subject: 'アカウントの有効化に関して'
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: 'パスワードリセットについて'
  end

  def notify_retirement(user, record)
    @user = user
    @record = record
    mail(to: @user.email, subject: 'ちゃくどん記録が無効になりました')
  end
end
