class FavoritesController < ApplicationController
  before_action :logged_in_user

  def create
    @ramen_shop = RamenShop.find(params[:ramen_shop_id])
    current_user.add_favorite(@ramen_shop)
    respond_to do |format|
      format.html { redirect_to @ramen_shop }
      format.turbo_stream
    end
  end

  def destroy
    @ramen_shop = Favorite.find(params[:id]).ramen_shop
    current_user.remove_favorite(@ramen_shop)
    respond_to do |format|
      format.html { redirect_to @ramen_shop, status: :see_other }
      format.turbo_stream
    end
  end
end
