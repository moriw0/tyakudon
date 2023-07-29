class TestModeController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def update
    @user = User.find(params[:id])
    @user.update!(user_params)
  end

  private

  def user_params
    params.require(:user).permit(:is_test_mode)
  end
end
