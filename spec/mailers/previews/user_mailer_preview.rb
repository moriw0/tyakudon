# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    user = User.first
    user.activation_token = User.new_token
    UserMailer.account_activation(user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    user = User.first
    user.reset_token = User.new_token
    UserMailer.password_reset(user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/notify_retirement
  def notify_retirement
    user = User.first
    record = user.records.first
    UserMailer.notify_retirement(user, record)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/shop_register_request
  def shop_register_request
    user = User.first
    request = user.shop_register_requests.first
    UserMailer.shop_register_request(user, request)
  end
end
