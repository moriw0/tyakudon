class RecordsController < ApplicationController
  include RecordsHelper

  before_action :logged_in_user, except: %i[show]
  before_action :set_record, except: %i[new create]
  before_action :correct_user, except: %i[show new create]
  before_action :set_ramen_shop, except: %i[new create retire]
  before_action :check_auto_retired, only: %i[measure calculate retire]
  before_action :disable_connect_button, only: %i[measure result]

  def show
    @tweet_url = generate_tweet_url(@record, request.url)
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
      capture_message_with_user_info('Record created')
    else
      set_ramen_shop
      render :new_with_errors, status: :unprocessable_entity
    end
  end

  def measure
    if @record.ended_at?
      redirect_to root_path, status: :see_other
    elsif remember_record?
      set_record_from_cookies
      flash.now.notice = '再接続しました'
    else
      remember_record
      flash.now.notice = '接続しました'
    end
  end

  def calculate
    if @record.ended_at?
      redirect_to root_path, status: :see_other
    else
      @record.calculate_action = true
      @record.update!(calculated_record_params)
      forget_record
      redirect_to result_record_path(@record), notice: 'ちゃくどんレコードを登録しました', status: :see_other
      capture_message_with_user_info('Record Calculated')
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
    @record.calculate_wait_time_for_retire!
    forget_record
    redirect_to root_path, notice: 'リタイアしました', status: :see_other
    capture_message_with_user_info('Record Retired')
  end

  private

  def set_record
    @record = Record.find(params[:id])
  end

  def correct_user
    user = User.find(@record.user.id)
    return if current_user?(user)

    flash.alert = '不正なアクセスです'
    redirect_to root_path, status: :see_other
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

  def check_auto_retired
    return unless @record.auto_retired?

    forget_record
    redirect_to root_path, notice: '記録は無効になっています', status: :see_other
  end
end
