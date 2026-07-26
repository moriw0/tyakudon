class LineStatusesController < ApplicationController
  before_action :logged_in_user
  before_action :use_v2_layout!, only: %i[new create]
  before_action :set_record, only: %i[new create]
  before_action :correct_user

  def new
    @line_status = @record.line_statuses.build
  end

  def create
    @line_status_counter = @record.line_statuses.size
    @line_status = @record.line_statuses.build(line_status_params)

    if @line_status.save
      flash.now.notice = '行列の様子を報告しました'
    else
      render :new_with_errors, status: :unprocessable_content
    end
  end

  private

  def set_record
    @record = Record.find(params[:record_id])
  end

  def correct_user
    user = User.find(@record.user.id)
    return if current_user?(user)

    flash.alert = '不正なアクセスです'
    redirect_to root_path, status: :see_other
  end

  def line_status_params
    params.require(:line_status).permit(:line_number, :line_type, :comment, :image)
  end
end
