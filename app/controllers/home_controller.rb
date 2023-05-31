class HomeController < ApplicationController
  def index
    @search = RamenShop.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @ramen_shops = @search.result.page(params[:page])
  end

  def search
  end
end
