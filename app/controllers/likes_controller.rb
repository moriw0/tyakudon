class LikesController < ApplicationController
  before_action :logged_in_user

  def create
    @record = Record.find(params[:record_id])
    current_user.add_like(@record)
  end

  def destroy
    @record = Like.find(params[:id]).record
    current_user.remove_like(@record)
  end

  def prepare
    @record = Record.find(params[:id])
    redirect_to record_path(@record)
  end
end
