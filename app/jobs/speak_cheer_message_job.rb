class SpeakCheerMessageJob < ApplicationJob
  queue_as :default

  MODEL_NAME = 'gpt-3.5-turbo'.freeze
  TEMPERATURE = 0.8

  def perform(record_id)
    record = Record.find(record_id)
    response = call_openai(record)

    message = record.cheer_messages.create!(
      role: 'assistant',
      content: response.dig('choices', 0, 'message', 'content')
    )

    message.broadcast_prepend_to(record, 'cheer_messages')
  end

  private

  def call_openai(record)
    OpenAI::Client.new.chat(
      parameters: {
        model: MODEL_NAME,
        messages: CheerMessage.for_openai(record.cheer_messages.recent),
        temperature: TEMPERATURE
      }
    )
  end
end
