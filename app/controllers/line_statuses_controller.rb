class LineStatusesController < ApplicationController
  def show
    @line_status = LineStatus.find(params[:id])
  end

  def new
    @record_line_status = LineStatus.new
  end

  def create
    @line_status = Record.find(params[:record_id]).line_statuses.build(line_status_param)

    if @line_status.save
      redirect_to @line_status, notice: '待ち状況を報告しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def line_status_param
    params.require(:line_status).permit(:line_number, :line_type, :comment)
  end
end
