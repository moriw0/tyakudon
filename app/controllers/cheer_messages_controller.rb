class CheerMessagesController < ApplicationController
  def create
    record = Record.find(params[:id])
    current_wait_time = params[:current_wait_time]

    #実行時間をランダムに生成
    # random_wait_time = rand(1..3)
    #実行時間を元にjobを生成
    # SpeakMessageJob.set(wait: random_wait_time.seconds).perform_later(@post, data['content'])
    # 一旦websocketでメッセージを挿入
    # message = post.messages.create(content: message)
    # message.broadcast_prepend_to("messages")

    # 純websocketでメッセージを出力
    RecordChannel.broadcast_to(record, message: '応援しておる')

    #jsonで返す
    if record
      render json: { id: record.id, waitTime: current_wait_time, message: '成功しました' }, status: :ok
    else
      render json: { message: 'Jobの生成に失敗しました。' }, status: :internal_server_error
    end
  end
end
