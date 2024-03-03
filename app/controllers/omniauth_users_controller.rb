class OmniauthUsersController < ApplicationController
  include Authenticatable

  def new
    unless (auth = session['auth_data'])
      return redirect_to root_path, alert: '不正なアクセスです'
    end

    email = auth['info']['email']
    @user = User.new(email: email)
  end

  def create
    user = User.new(user_params)
    user.build_with_omniauth(session['auth_data'])

    if user.save
      user.activate
      handle_authentication(user, remember: true)
    else
      render 'new', status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :avatar)
  end
end
