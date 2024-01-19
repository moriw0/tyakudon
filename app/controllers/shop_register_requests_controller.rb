class ShopRegisterRequestsController < ApplicationController
  before_action :logged_in_user

  def new
    @request = ShopRegisterRequest.new
  end

  def create
    @request = current_user.shop_register_requests.build(request_params)

    if shop_exists?
      handle_existing_shop
    else
      save_request
    end
  end

  private

  def request_params
    params.require(:shop_register_request).permit(:name, :address, :remarks)
  end

  def update_request_params
    params.require(:shop_register_request).permit(:name, :address, :remarks, :status)
  end

  def shop_exists?
    RamenShop.exists?(name: @request.name, address: @request.address)
  end

  def handle_existing_shop
    flash.now[:alert] = '店舗が既に存在します。'
    @ramen_shop = RamenShop.find_by(name: @request.name, address: @request.address)
    render :new, status: :unprocessable_entity
  end

  def save_request
    if @request.save
      @request.user.send_shop_register_request_email(@request)
      redirect_to root_path, notice: 'リクエストを送信しました'
    else
      render :new, status: :unprocessable_entity
    end
  end
end
