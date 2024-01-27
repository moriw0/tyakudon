# Preview all emails at http://localhost:3000/rails/mailers/shop_register_mailer
class ShopRegisterMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/shop_register_mailer/shop_register_request
  def shop_register_request
    user = User.first
    request = user.shop_register_requests.first
    ShopRegisterMailer.shop_register_request(request)
  end

  # Preview this email at http://localhost:3000/rails/mailers/shop_register_mailer/registration_complete_email
  def registration_complete_email
    user = User.first
    ramen_shop = RamenShop.first
    ShopRegisterMailer.registration_complete_email(user: user, ramen_shop: ramen_shop)
  end
end
