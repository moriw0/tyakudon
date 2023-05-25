class RecordsController < ApplicationController
  def new
    @ramen_shop = RamenShop.find(params[:ramen_shop_id])
    @ramen_shop_record = @ramen_shop.records.build
    @ramen_shop_record.line_statuses.build
    # @ramen_shop_record = @ramen_shop.records.build(
    #   started_at: Time.current
    # )
  end

  def create
    ramen_shop = RamenShop.find(params[:ramen_shop_id])
    record = Record.new(record_param)

    if record.save
      redirect_to ramen_shop_record_measure_path(ramen_shop, record)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def measure
    @ramen_shop = RamenShop.find(params[:ramen_shop_id])
    @record = Record.find(params[:record_id])

    if @record.update(started_at: Time.current)
      flash.notice = "セツゾクしました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @record = Record.new(record_param).calculate_wait_time!

    if @record.save
      redirect_to ramen_shop_path(@record.ramen_shop), notice: 'Record was successfully created.'
    else
      render :new
    end
  end

  private

  def record_param
    params.require(:record).permit(:ramen_shop_id, :started_at, line_statuses_attributes: [:line_number, :line_type])
  end
end
