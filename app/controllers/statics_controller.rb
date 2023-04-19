class StaticsController < ApplicationController
  def index
    @ramen_shops = RamenShop.all

    respond_to do |format|
      format.html
      format.json { render json: @ramen_shops }
    end
  end

  def about
  end
end
