class NewRecordsController < ApplicationController
  def index
    @records = Record.new_records.page(params[:page])
  end
end
