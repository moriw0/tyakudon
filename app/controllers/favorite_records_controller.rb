class FavoriteRecordsController < ApplicationController
  before_action :logged_in_user, only: %i[filter]

  def index
    return unless logged_in?

    @checked_ids = set_checked_ids
    @records = fetch_records.page(params[:page])
  end

  def filter
    @checked_ids = params[:shop_ids]&.compact_blank&.map(&:to_i)
  end

  private

  def set_checked_ids
    return params[:shop_ids].compact_blank.map(&:to_i) if params[:shop_ids]

    current_user.favorite_shop_ids
  end

  def fetch_records
    return Record.filter_by_shop_ids(@checked_ids) if params[:shop_ids]

    Record.favorite_records_from(current_user)
  end
end
