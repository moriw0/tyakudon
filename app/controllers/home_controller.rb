class HomeController < ApplicationController
  def index
    @ramen_shops = RamenShop.all
  end

  def search
  end
end
