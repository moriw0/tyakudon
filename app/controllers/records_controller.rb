class RecordsController < ApplicationController
  before_action :set_record, only: %i[show measure edit update]
  before_action :set_ramen_shop, except: %i[new create]

  def show
  end

  def new
    @ramen_shop = RamenShop.find(params[:ramen_shop_id])
    @record = @ramen_shop.records.build
    @record.line_statuses.build
  end

  def edit
  end

  def create
    @record = Record.new(record_param)

    if @record.save!
      redirect_to measure_record_path(@record), status: :see_other
    else
      set_ramen_shop
      render :new_with_errors, status: :unprocessable_entity
    end
  end

  def measure
    if @record.update(started_at: Time.current)
      flash.notice = 'セツゾクしました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @record.assign_attributes(record_param)
    @record.calculate_wait_time!

    if @record.save
      redirect_to record_path(@record), notice: 'ちゃくどんレコードを登録しました'
    else
      render :new
    end
  end

  private

  def set_record
    @record = Record.find(params[:id])
  end

  def set_ramen_shop
    @ramen_shop = @record.ramen_shop
  end

  def record_param
    params.require(:record).permit(:ramen_shop_id, :started_at, :ended_at,
                                   line_statuses_attributes: %i[line_number line_type comment])
  end
end
