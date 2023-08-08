class HomeController < ApplicationController
  before_action :logged_in_user, only: %i[search]
  before_action :set_search, only: %i[index record_ranking new_records]
  before_action :disable_connect_button, only: %i[search]

  def index
    @ranking_records = Record.unscoped.where(is_retired: false, auto_retired: false).order('wait_time DESC').limit(5)
    @new_records = Record.where(is_retired: false, auto_retired: false).take(5)
  end

  def record_ranking
    @records = Record.unscoped.where(is_retired: false, auto_retired: false).page(params[:page])
  end

  def new_records
    @records = Record.where(is_retired: false, auto_retired: false).page(params[:page])
  end

  def search
  end

  private

  def set_search
    @search = RamenShop.ransack(params[:q])
  end
end
