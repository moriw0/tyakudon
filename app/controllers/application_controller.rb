class ApplicationController < ActionController::Base
  before_action :redirect_subdomain
  before_action :handle_v2_flag

  layout :resolve_layout

  include SessionsHelper

  private

  def resolve_layout
    cookies[:v2_ui].present? && v2_layout_opted_in? ? 'v2' : 'application'
  end

  def v2_layout_opted_in?
    @v2_layout == true
  end

  def use_v2_layout!
    @v2_layout = true
    request.variant = :v2 if cookies[:v2_ui].present? # rubocop:disable Naming/VariableNumber
  end

  def handle_v2_flag
    if params[:v2] == '1' # rubocop:disable Naming/VariableNumber
      cookies.permanent[:v2_ui] = '1'
    elsif params[:v2] == '0' # rubocop:disable Naming/VariableNumber
      cookies.delete(:v2_ui)
    end
  end

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

  def capture_message_with_user_info(message)
    set_user_info
    Sentry.capture_message(message, level: :info)
  end

  def set_user_info
    Sentry.set_user(
      id: current_user.id,
      name: current_user.name
    )

    Sentry.configure_scope do |scope|
      scope.set_context(
        'user_details',
        { user_url: user_url(current_user) }
      )
    end
  end
end
