class RecordsController < ApplicationController
  def new
    @ramen_shop = RamenShop.find(params[:ramen_shop_id])
    @ramen_shop_record = @ramen_shop.records.build
    @ramen_shop_record.line_statuses.build
  end

  def create
    ramen_shop = RamenShop.find(params[:ramen_shop_id])
    ramen_shop_record = Record.new(record_param)

    if ramen_shop_record.save
      redirect_to ramen_shop_record_measure_path(ramen_shop, ramen_shop_record)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def measure
    @ramen_shop = RamenShop.find(params[:ramen_shop_id])
    @ramen_shop_record = Record.find(params[:id])

    if @ramen_shop_record.update(started_at: Time.current)
      flash.notice = "セツゾクしました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @ramen_shop = RamenShop.find(params[:ramen_shop_id])
    @ramen_shop_record = Record.find(params[:id])
  end

  def update
    ramen_shop_record = Record.find(params[:id])
    ramen_shop_record.assign_attributes(record_param)
    ramen_shop_record.calculate_wait_time!

    if ramen_shop_record.save
      redirect_to ramen_shop_path(ramen_shop_record.ramen_shop), notice: 'ちゃくどんレコードを登録しました'
    else
      render :new
    end
  end

  private

  def record_param
    params.require(:record).permit(:ramen_shop_id, :started_at, :ended_at, line_statuses_attributes: [:line_number, :line_type])
  end
end
