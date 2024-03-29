class ShopRegisterRequestsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user, only: %i[edit complete]

  def new
    @request = ShopRegisterRequest.new
  end

  def edit
    request = ShopRegisterRequest.find_by(id: params[:id])

    return redirect_to root_path, alert: '無効なリンクです' unless request&.open?

    request.approved!
    redirect_to new_ramen_shop_path(request: { id: request.id, name: request.name, address: request.address })
  end

  def create
    @request = current_user.shop_register_requests.build(request_params)

    return handle_existing_shop if RamenShop.exists?(name: @request.name, address: @request.address)

    save_request
  end

  def complete
    request = ShopRegisterRequest.find_by(id: params[:id])
    ramen_shop = RamenShop.find_by(id: params[:ramen_shop_id])

    return complete_registration(request, ramen_shop) if request&.approved? && ramen_shop

    redirect_to root_path, alert: '不正なアクセスです'
  end

  private

  def request_params
    params.require(:shop_register_request).permit(:name, :address, :remarks)
  end

  def handle_existing_shop
    flash.now[:alert] = '店舗が既に存在します。'
    @ramen_shop = RamenShop.find_by(name: @request.name, address: @request.address)
    render :new, status: :unprocessable_entity
  end

  def save_request
    return render :new, status: :unprocessable_entity unless @request.save

    ShopRegisterMailer.shop_register_request(@request).deliver_now
    redirect_to root_path, notice: 'リクエストを送信しました'
  end

  def complete_registration(request, ramen_shop)
    ShopRegisterMailer.registration_complete_email(user: request.user, ramen_shop: ramen_shop).deliver_now
    request.completed!
    redirect_to root_path, notice: '登録完了メールを送信しました'
  end
end
