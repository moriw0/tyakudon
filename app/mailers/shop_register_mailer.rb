class ShopRegisterMailer < ApplicationMailer
  def shop_register_request(request)
    @request = request
    mail(to: ENV.fetch('ADMIN_EMAIL'), subject: '店舗登録リクエスト')
  end

  def registration_complete_email(user:, ramen_shop:)
    @user = user
    @ramen_shop = ramen_shop
    mail(to: @user.email, subject: '店舗登録が完了しました | ちゃくどん')
  end
end
