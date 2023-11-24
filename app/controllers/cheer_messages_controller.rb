class CheerMessagesController < ApplicationController
  def create
    record = Record.find(params[:id])
    current_wait_time = params[:current_wait_time]
    message = record.cheer_messages.build(content: '最近応援している')

    if message.save
      random_wait_time = rand(1..3)
      SpeakMessageJob.set(wait: random_wait_time.seconds).perform_later(message)

      render json: { id: record.id, waitTime: current_wait_time, message: '成功しました' }, status: :ok
    else
      render json: { message: 'Jobの生成に失敗しました。' }, status: :internal_server_error
    end
  end
end
