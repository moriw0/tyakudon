class HomeController < ApplicationController
  include SessionsHelper

  before_action :logged_in_user, only: %i[search]
  before_action :set_search, only: %i[index record_ranking new_records]
  before_action :disable_connect_button, only: %i[search]

  def index
    @ranking_records = Record.ranking_records.top_five
    @new_records = Record.new_records.top_five
    @favorite_shops_records = current_user.records_from_favorite_shops if logged_in?
  end

  def record_ranking
    @records = Record.unscoped.ranking_records.page(params[:page])
    @offset = (@records.current_page - 1) * @records.limit_value
  end

  def new_records
    @records = Record.new_records.page(params[:page])
  end

  def search
  end

  private

  def set_search
    @search = RamenShop.ransack(params[:q])
  end
end
