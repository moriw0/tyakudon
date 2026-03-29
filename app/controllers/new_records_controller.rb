class NewRecordsController < ApplicationController
  before_action :use_v2_layout!, only: %i[index]

  def index
    @records = Record.new_records.page(params[:page])
  end
end
