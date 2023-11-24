class SpeakMessageJob < ApplicationJob
  queue_as :default

  def perform(message)
    message.broadcast_prepend_to('cheer_messages')
  end
end
