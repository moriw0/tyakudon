class RecordsController < ApplicationController
  include RecordsHelper

  before_action :logged_in_user, only: %i[new edit create measure update]
  before_action :set_record, only: %i[show measure edit update]
  before_action :set_ramen_shop, except: %i[new create]
  before_action :disable_connect_button, only: %i[measure]

  def show
  end

  def new
    @ramen_shop = RamenShop.find(params[:ramen_shop_id])
    @record = current_user.records.build(ramen_shop: @ramen_shop)
    @record.line_statuses.build
  end

  def edit
  end

  def create
    @record = Record.new(record_param)

    if @record.save
      redirect_to measure_record_path(@record), status: :see_other
    else
      set_ramen_shop
      render :new_with_errors, status: :unprocessable_entity
    end
  end

  def measure
    if remember_record?
      set_record_from_cookies
      flash.notice = '再セツゾクしました'
    elsif @record.ended_at?
      redirect_to root_path, status: :see_other
    else
      remember_record
      @record.update(started_at: Time.current)
      flash.notice = 'セツゾクしました'
    end
  end

  def update
    @record.assign_attributes(record_param)
    @record.calculate_wait_time!

    if @record.save
      forget_record
      redirect_to record_path(@record), notice: 'ちゃくどんレコードを登録しました', status: :see_other
    else
      render :edit
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
    params.require(:record).permit(:ramen_shop_id, :started_at, :ended_at, :comment, :user_id,
                                   line_statuses_attributes: %i[line_number line_type comment])
  end

  def set_record_from_cookies
    @record = Record.find(fetch_record_id)
  end

  def remember_record
    cookies.encrypted[:record_id] = { value: @record.id, expires: 1.day }
  end

  def forget_record
    cookies.delete(:record_id)
  end
end
