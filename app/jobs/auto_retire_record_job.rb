class AutoRetireRecordJob < ApplicationJob
  queue_as :default

  def perform(record)
    record.auto_retire!
    UserMailer.notify_retirement(record.user, record).deliver_now
  end
end
