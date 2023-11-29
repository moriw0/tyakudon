class CheerMessagesController < ApplicationController
  def create
    record = Record.find(params[:id])
    current_wait_time = params[:current_wait_time]
    line_status = record.line_statuses.last

    record.cheer_messages.create!(
      role: 'user',
      content: CheerMessage.build_send_message(current_wait_time, line_status)
    )

    SpeakCheerMessageJob.perform_later(record.id)

    render json: { message: 'Jobの生成に成功しました' }, status: :ok
  end
end
