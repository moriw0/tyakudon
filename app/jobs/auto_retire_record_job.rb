class AutoRetireRecordJob < ApplicationJob
  queue_as :default

  def perform(record)
    return if record.ended_at?

    record.auto_retire!
    UserMailer.notify_retirement(record.user, record).deliver_now
  end
end
