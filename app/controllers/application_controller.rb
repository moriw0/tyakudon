class ApplicationController < ActionController::Base
  include SessionsHelper

  def route_based_on_authentication
    if logged_in?
      redirect_to ranking_path
    else
      redirect_to lp_path
    end
  end

  private

  def logged_in_user
    return if logged_in?

    store_location
    flash.alert = 'ログインしてください'
    redirect_to login_url, status: :see_other
  end

  def admin_user
    redirect_to root_url, status: :see_other, notice: '不正なアクセスです' unless current_user.admin?
  end

  def disable_connect_button
    @show_connect_button = false
  end
end
