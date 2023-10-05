class HomeController < ApplicationController
  include SessionsHelper

  before_action :logged_in_user, only: %i[favorite_records search]
  before_action :set_search, except: %i[search]
  before_action :disable_connect_button, only: %i[search]

  def index
    @ranking_records = Record.ranking_records.top_five
    @new_records = Record.new_records.top_five
    @favorite_records = Record.favorite_records_from(current_user).top_five if logged_in?
  end

  def favorite_records
    @records = Record.favorite_records_from(current_user).page(params[:page])
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
