class BroadcastImageJob < ApplicationJob
  queue_as :default

  def perform(record_id)
    record = Record.find_by(id: record_id)
    return unless record&.image&.attached?

    unless record.image.blob.variant_records.exists?
      retry_job wait: 5.seconds if executions < 12
      return
    end

    broadcast_image(record)
  end

  private

  def broadcast_image(record)
    Turbo::StreamsChannel.broadcast_replace_to(
      [record, 'image'],
      target: ActionView::RecordIdentifier.dom_id(record, :image),
      partial: 'records/image',
      locals: { record: record }
    )
  end
end
