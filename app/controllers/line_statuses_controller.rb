class LineStatusesController < ApplicationController
  before_action :set_line_status, only: %i[show edit update]

  def show
  end

  def new
    @record_line_status = LineStatus.new
  end

  def create
    @line_status = Record.find(params[:record_id]).line_statuses.build(line_status_params)

    if @line_status.save
      redirect_to @line_status, notice: '待ち状況を報告しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @line_status.update(line_status_params)
      redirect_to @line_status, notice: '待ち状況を更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_line_status
    @line_status = LineStatus.find(params[:id])
  end

  def line_status_params
    params.require(:line_status).permit(:line_number, :line_type, :comment)
  end
end
