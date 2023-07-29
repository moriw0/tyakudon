require 'rails_helper'

RSpec.describe 'LineStatuses' do
  let(:user) { create(:user) }
  let(:record) { create(:record, user: user ) }
  let(:line_status) { create(:line_status, record: record) }

  shared_examples 'when not logged in' do
    it 'redirects to login_path' do
      do_request
      expect(response).to redirect_to login_path
    end
  end

  describe 'GET /line_statuses/:id #show' do
    it 'returns line_status information' do
      get line_status_path(line_status)
      expect(response.body).to include "<p>待ち人数: #{line_status.line_number}</p>"
    end
  end

  describe 'GET /records/:record_id/line_statuses/new #new' do
    let(:do_request) { get new_record_line_status_path(record), as: :turbo_stream }

    it_behaves_like 'when not logged in'

    it 'returns new modal when logged in' do
      log_in_as(user)
      do_request
      expect(response.body).to include '<h5 class="modal-title">登録</h5>'
    end
  end

  describe 'GET /line_statuses/:id/edit #edit' do
    let(:do_request) { get edit_line_status_path(line_status), as: :turbo_stream }

    it_behaves_like 'when not logged in'

    it 'returns edit modal when logged in' do
      log_in_as(user)
      do_request
      expect(response.body).to include '<h5 class="modal-title">編集</h5>'
    end
  end

  describe 'POST /records/:record_id/line_statuses #create' do
    let(:do_request) { post record_line_statuses_path(record), params: line_satus_params, as: :turbo_stream }
    let(:line_satus_params) { { line_status: attributes_for(:line_status) } }

    it_behaves_like 'when not logged in'

    context 'when logged in' do
      before do
        log_in_as(user)
      end

      it 'creates a line_status' do
        expect {
          do_request
        }.to change(LineStatus, :count).by(1)
      end
    end
  end

  describe 'PATCH /line_statuses/:id #update' do
    let(:do_request) { patch line_status_path(line_status), params: line_satus_params, as: :turbo_stream }
    let(:line_satus_params) { { line_status: attributes_for(:line_status, line_number: 4) } }

    it_behaves_like 'when not logged in'

    it 'updates line_status from 5 to 4 when logged in' do
      log_in_as(user)
      line_status.update(line_number: 5)
      do_request
      expect(line_status.reload.line_number).to eq 4
    end
  end
end
