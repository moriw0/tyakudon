class RecordsController < ApplicationController
  include RecordsHelper

  before_action :logged_in_user, except: %i[show]
  before_action :set_record, except: %i[new create]
  before_action :set_ramen_shop, except: %i[new create retire]
  before_action :disable_connect_button, only: %i[measure result]

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
    @record = Record.new(create_record_params)

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
    elsif @record.ended_at? || @record.is_retired?
      redirect_to root_path, status: :see_other
    else
      remember_record
      flash.notice = 'セツゾクしました'
    end
  end

  def calculate
    if @record.ended_at?
      redirect_to root_path, status: :see_other
    else
      @record.update!(calculated_record_params)
      forget_record
      redirect_to result_record_path(@record), notice: 'ちゃくどんレコードを登録しました', status: :see_other
    end
  end

  def result
  end

  def update
    if @record.update(update_record_params)
      redirect_to record_path(@record), notice: '投稿しました', status: :see_other
    else
      render :result, status: :unprocessable_entity
    end
  end

  def retire
    @record.update!(is_retired: true)
    forget_record
    redirect_to root_path, notice: 'リタイアしました', status: :see_other
  end

  private

  def set_record
    @record = Record.find(params[:id])
  end

  def set_ramen_shop
    @ramen_shop = @record.ramen_shop
  end

  def create_record_params
    params.require(:record).permit(:ramen_shop_id, :user_id, :started_at,
                                   line_statuses_attributes: %i[line_number line_type comment image])
  end

  def calculated_record_params
    params.require(:record).permit(:ended_at, :wait_time)
  end

  def update_record_params
    params.require(:record).permit(:comment, :image)
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
