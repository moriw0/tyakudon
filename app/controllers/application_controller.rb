class ApplicationController < ActionController::Base
  before_action :redirect_subdomain

  include SessionsHelper

  def route_based_on_authentication
    if logged_in?
      redirect_to ranking_path
    else
      redirect_to lp_path
    end
  end

  private

  def redirect_subdomain
    return unless request.host == 'tyakudon.fly.dev'

    redirect_to "https://tyakudon.com#{request.fullpath}", status: :moved_permanently, allow_other_host: true
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash.alert = 'ログインが必要です'
      redirect_to login_path, status: :see_other
      return
    end

    check_user_activation
  end

  def check_user_activation
    return if current_user.activated?

    flash.alert = 'アカウントを有効化する必要があります。メールを確認してください。'
    redirect_to root_path, status: :see_other
  end

  def admin_user
    redirect_to root_url, status: :see_other, notice: '不正なアクセスです' unless current_user.admin?
  end

  def disable_connect_button
    @show_connect_button = false
  end
end
