class RamenShopsController < ApplicationController
  def index
    @ramen_shops = RamenShop.all

    respond_to do |format|
      format.html
      format.json { render json: @ramen_shops }
    end
  end

  def show
    @ramen_shop = RamenShop.find(params[:id])
    @records = @ramen_shop.records.page(params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @ramen_shop.as_json(include: :records) }
    end
  end

  TARGET_RADIUS = 0.1
  def near_shops
    current_lat = params[:lat].to_f
    current_lng = params[:lng].to_f

    @ramen_shops = RamenShop.near([current_lat, current_lng], TARGET_RADIUS)
    render json: @ramen_shops
  end
end
