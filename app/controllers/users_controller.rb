class UsersController < ApplicationController
  before_action :logged_in_user, only: %i[index edit update destroy favorite_shops update_test_mode]
  before_action :correct_user, only: %i[edit update favorite_shops]
  before_action :admin_user, only: %i[index destroy update_test_mode]
  before_action :disable_connect_button, only: %i[new edit]

  def index
    @users = User.where(activated: true).page(params[:page])
  end

  def show
    @user = User.find(params[:id])
    @records = @user.records.active_ordered.page(params[:page])
    redirect_to root_path and return unless @user.activated
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @user.send_activation_email
      redirect_to root_path, notice: 'メールを確認してアカウントを有効にしてください'
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      flash.notice = 'ユーザー情報を更新しました'
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to users_url, status: :see_other, notice: 'ユーザーを削除しました'
  end

  def favorite_shops
    @user = User.find(params[:id])
    @ramen_shops = @user.favorite_shops.page(params[:page])
  end

  def update_test_mode
    @user = User.find(params[:id])
    @user.update!(test_mode_param)
    flash.now.notice = 'saved!'
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation, :avatar)
  end

  def test_mode_param
    params.require(:user).permit(:is_test_mode)
  end

  def correct_user
    @user = User.find(params[:id])
    return if current_user?(@user)

    flash.alert = '不正なアクセスです'
    redirect_to root_path, status: :see_other
  end
end
