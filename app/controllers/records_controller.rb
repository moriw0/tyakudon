class RecordsController < ApplicationController
  def new
    @record = Record.new
  end

  def create
    @record = Record.new(record_param)

    if @record.save
      render json: { status: 'succsess' }, status: :ok
    else
      render json: { status: 'error' }, status: :unprocessable_entity
    end
  end

  private

  def record_param
    params.require(:record).permit(:ramen_shop_id, :started_at, :ended_at, :elapsed_time)
  end
end
