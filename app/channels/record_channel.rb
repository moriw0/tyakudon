class RecordChannel < ApplicationCable::Channel
  def subscribed
    record = Record.find(params[:id])
    stream_for record
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def cheer(data)
    @record = Record.find(data['id'])
    RecordChannel.broadcast_to(@record, message: data['content'])
    # random_wait_time = rand(1..3)
    # EncourageJob.set(wait: random_wait_time.seconds).perform_later(@post, data['content'])
  end
end
