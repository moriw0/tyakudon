class RankingRecordsController < ApplicationController
  def index
    @records = Record.ranking_by(sort_type: params[:sort], page: params[:page])
    @offset = calculate_page_offset
  end

  private

  def calculate_page_offset
    (@records.current_page - 1) * @records.limit_value
  end
end
