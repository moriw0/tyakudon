class HomeController < ApplicationController
  before_action :logged_in_user, only: %i[search]
  before_action :disable_connect_button, only: %i[search]

  def index
    @search = RamenShop.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @ramen_shops = @search.result.page(params[:page])
  end

  def search
  end
end
