class HomeController < ApplicationController
  def index
    @ramen_shops = RamenShop.page(params[:page])
  end

  def search
  end
end
