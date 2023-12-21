class FavoriteRecordsController < ApplicationController
  before_action :logged_in_user, only: %i[filter]
  before_action :set_checked_ids, only: %i[index filter]

  def index
    @records = fetch_records.page(params[:page]) if logged_in?
  end

  def filter
  end

  private

  def set_checked_ids
    @checked_ids = if params[:shop_ids].present?
                     params[:shop_ids].compact_blank.map(&:to_i)
                   elsif logged_in?
                     current_user.favorite_shop_ids
                   end
  end

  def fetch_records
    if params[:shop_ids].present?
      Record.filter_by_shop_ids(@checked_ids)
    else
      Record.favorite_records_from(current_user)
    end
  end
end
