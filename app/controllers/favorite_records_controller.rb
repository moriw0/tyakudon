class FavoriteRecordsController < ApplicationController
  def index
    @records = Record.favorite_records_from(current_user).page(params[:page]) if logged_in?
  end
end
