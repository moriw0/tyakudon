class HomeController < ApplicationController
  before_action :logged_in_user, only: %i[search]
  before_action :disable_connect_button, only: %i[search]

  def index
    @search = RamenShop.ransack(params[:q])
    @ranking_records = Record.unscoped.where(is_retired: false, auto_retired: false).order('wait_time DESC').limit(5)
    @new_records = Record.where(is_retired: false, auto_retired: false).take(5)
  end

  def search
  end
end
