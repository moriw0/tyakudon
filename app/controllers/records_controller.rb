class RecordsController < ApplicationController
  before_action :set_ramen_shop
  before_action :set_ramen_shop_record, only: %i[show measure edit update]

  def show
  end

  def new
    @ramen_shop_record = @ramen_shop.records.build
    @ramen_shop_record.line_statuses.build
  end

  def create
    ramen_shop_record = Record.new(record_param)

    if ramen_shop_record.save
      redirect_to measure_ramen_shop_record_path(@ramen_shop, ramen_shop_record)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def measure
    if @ramen_shop_record.update(started_at: Time.current)
      flash.notice = "セツゾクしました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @ramen_shop_record.assign_attributes(record_param)
    @ramen_shop_record.calculate_wait_time!

    if @ramen_shop_record.save
      redirect_to ramen_shop_record_path(@ramen_shop, @ramen_shop_record), notice: 'ちゃくどんレコードを登録しました'
    else
      render :new
    end
  end

  private

  def set_ramen_shop
    @ramen_shop = RamenShop.find(params[:ramen_shop_id])
  end

  def set_ramen_shop_record
    @ramen_shop_record = Record.find(params[:id])
  end

  def record_param
    params.require(:record).permit(:ramen_shop_id, :started_at, :ended_at, line_statuses_attributes: [:line_number, :line_type])
  end
end
