class LineStatusesController < ApplicationController
  before_action :logged_in_user, except: %i[show]
  before_action :set_record, only: %i[new create]
  before_action :set_line_status, only: %i[show edit update]

  def show
  end

  def new
    @line_status = @record.line_statuses.build
  end

  def edit
  end

  def create
    @line_status = @record.line_statuses.build(line_status_params)

    if @line_status.save
      flash.now.notice = '行列の様子を報告しました'
    else
      render :new_with_errors, status: :unprocessable_entity
    end
  end

  def update
    if @line_status.update(line_status_params)
      flash.now.notice = '待ち状況を更新しました'
    else
      render :edit_with_errors, status: :unprocessable_entity
    end
  end

  private

  def set_record
    @record = Record.find(params[:record_id])
  end

  def set_line_status
    @line_status = LineStatus.find(params[:id])
  end

  def line_status_params
    params.require(:line_status).permit(:line_number, :line_type, :comment, :image)
  end
end
