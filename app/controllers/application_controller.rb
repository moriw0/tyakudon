class ApplicationController < ActionController::Base
  include SessionsHelper

  private

  def logged_in_user
    return if logged_in?

    store_location
    flash.alert = 'ログインしてください'
    redirect_to login_url, status: :see_other
  end
end
