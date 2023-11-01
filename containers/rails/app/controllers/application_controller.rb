class ApplicationController < ActionController::Base
  include SessionsHelper

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
