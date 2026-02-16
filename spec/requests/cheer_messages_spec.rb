require 'rails_helper'

RSpec.describe 'CheerMessages' do
  describe 'POST /cheer_messages #create' do
    let!(:user) { create(:user) }
    let!(:record) { create(:record, :with_line_status, user: user) }

    before do
      allow(SpeakCheerMessageJob).to receive(:perform_later)
    end

    context 'with a valid record' do
      it 'creates a cheer_message with user role' do
        expect {
          post cheer_messages_path, params: { id: record.id, current_wait_time: 600 }, as: :json
        }.to change(CheerMessage, :count).by(1)
      end

      it 'enqueues SpeakCheerMessageJob' do
        post cheer_messages_path, params: { id: record.id, current_wait_time: 600 }, as: :json
        expect(SpeakCheerMessageJob).to have_received(:perform_later).with(record.id)
      end

      it 'returns 200 OK with JSON response' do
        post cheer_messages_path, params: { id: record.id, current_wait_time: 600 }, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['message']).to eq('Jobの生成に成功しました')
      end
    end

    context 'when record does not exist' do
      it 'returns 404 not found' do
        post cheer_messages_path, params: { id: 0, current_wait_time: 600 }, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
