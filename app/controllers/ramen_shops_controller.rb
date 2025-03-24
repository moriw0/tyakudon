class RamenShopsController < ApplicationController
  before_action :logged_in_user, only: %i[new edit create update prepare_favorite]
  before_action :admin_user,     only: %i[new edit create update]
  before_action :set_ramen_shop, only: %i[show edit update prepare_favorite]

  def index
    @search = RamenShop.search_by_keywords(params[:q])
    @result_count = @search.result.count
    @ramen_shops = @search.result.page(params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @ramen_shops }
    end
  end

  def show
    @records = @ramen_shop.records.with_associations.active_ordered.page(params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @ramen_shop.as_json(include: :records) }
    end
  end

  def new
    return @ramen_shop = RamenShop.new if params[:request].blank?

    @ramen_shop = RamenShop.new(name: params[:request][:name], address: params[:request][:address])
    @request_id = params[:request][:id]
  end

  def edit
  end

  def create
    @ramen_shop = RamenShop.new(ramen_shop_params)
    @request_id = params[:request_id]

    if @ramen_shop.save
      process_after_save
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @ramen_shop.update(ramen_shop_params)
      redirect_to ramen_shop_path(@ramen_shop), notice: 'saved!'
    else
      render :edit, status: :unprocessable_entity
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

  def process_after_save
    if @request_id
      redirect_to complete_shop_register_request_path(params[:request_id], ramen_shop_id: @ramen_shop.id)
    else
      redirect_to new_ramen_shop_path, notice: 'saved!'
    end
  end
end
