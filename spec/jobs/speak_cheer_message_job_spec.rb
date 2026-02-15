require 'rails_helper'

RSpec.describe SpeakCheerMessageJob do
  include ActiveJob::TestHelper

  let!(:user) { create(:user) }
  let!(:record) { create(:record, :with_line_status, user: user) }
  let(:openai_response) do
    { 'choices' => [{ 'message' => { 'content' => '応援メッセージどん！' } }] }
  end
  let(:openai_client) { instance_double(OpenAI::Client, chat: openai_response) }

  before do
    clear_enqueued_jobs
    clear_performed_jobs
    allow(OpenAI::Client).to receive(:new).and_return(openai_client)
  end

  describe '#perform' do
    it 'creates an assistant cheer_message' do
      expect {
        perform_enqueued_jobs { described_class.perform_later(record.id) }
      }.to change { record.cheer_messages.count }.by(1)
    end

    it 'creates a cheer_message with assistant role' do
      perform_enqueued_jobs { described_class.perform_later(record.id) }
      message = record.cheer_messages.last
      expect(message.role).to eq('assistant')
    end

    it 'stores the response content from OpenAI' do
      perform_enqueued_jobs { described_class.perform_later(record.id) }
      message = record.cheer_messages.last
      expect(message.content).to eq('応援メッセージどん！')
    end

    it 'broadcasts the message to the record channel' do
      expect_any_instance_of(CheerMessage).to receive(:broadcast_prepend_to).with(record, 'cheer_messages') # rubocop:disable RSpec/AnyInstance
      perform_enqueued_jobs { described_class.perform_later(record.id) }
    end
  end
end
