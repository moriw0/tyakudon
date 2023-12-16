class RankingRecordsController < ApplicationController
  def index
    @records = Record.ranking_by(params[:sort], params[:page])
    @offset = calculate_page_offset(@records)
  end

  private

  def calculate_page_offset(records)
    (records.current_page - 1) * records.limit_value
  end
end
