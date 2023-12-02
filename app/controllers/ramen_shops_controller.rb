class RamenShopsController < ApplicationController
  before_action :logged_in_user, only: %i[new edit create update prepare_favorite]
  before_action :admin_user,     only: %i[new edit create update]
  before_action :set_ramen_shop, only: %i[show show_with_map edit update prepare_favorite]

  def index
    @search = RamenShop.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @ramen_shops = @search.result.page(params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @ramen_shops }
    end
  end

  def show
    @records = @ramen_shop.records.active_ordered.page(params[:page])
    @show_map = false

    respond_to do |format|
      format.html
      format.json { render json: @ramen_shop.as_json(include: :records) }
    end
  end

  def show_with_map
    @records = @ramen_shop.records.active_ordered.page(params[:page])
    @show_map = true
  end

  def new
    @ramen_shop = RamenShop.new
  end

  def edit
  end

  def create
    ramen_shop = RamenShop.new(ramen_shop_params)

    if ramen_shop.save
      redirect_to new_ramen_shop_path, notice: 'saved!'
    else
      render :new
    end
  end

  def update
    if @ramen_shop.update(ramen_shop_params)
      redirect_to ramen_shop_path(@ramen_shop), notice: 'saved!'
    else
      render :edit
    end
  end

  TARGET_RADIUS = 0.1
  def near_shops
    current_lat = params[:lat].to_f
    current_lng = params[:lng].to_f

    @ramen_shops = RamenShop.near([current_lat, current_lng], TARGET_RADIUS)
    render json: @ramen_shops
  end

  def prepare_favorite
    redirect_to ramen_shop_path(@ramen_shop)
  end

  private

  def set_ramen_shop
    @ramen_shop = RamenShop.find(params[:id])
  end

  def ramen_shop_params
    params.require(:ramen_shop).permit(:name, :address)
  end
end
