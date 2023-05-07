class RecordsController < ApplicationController
  def new
    @ramen_shop = RamenShop.find(params[:ramen_shop_id])
    @ramen_shop_record = @ramen_shop.records.build(
      started_at: Time.current
    )
  end

  def create
    @record = Record.new(record_param).calculate_wait_time!

    if @record.save
      redirect_to ramen_shop_path(@record.ramen_shop), notice: 'Record was successfully created.'
    else
      render :new
    end
  end

  private

  def record_param
    params.require(:record).permit(:ramen_shop_id, :started_at, :queue_number)
  end
end
