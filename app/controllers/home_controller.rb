class HomeController < ApplicationController
  before_action :logged_in_user, only: %i[search]
  before_action :set_search, except: %i[search]
  before_action :disable_connect_button, only: %i[search]

  def favorite_records
    @records = Record.favorite_records_from(current_user).page(params[:page]) if logged_in?
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
