require 'rails_helper'

RSpec.describe 'LineStatuses' do
  let(:user) { create(:user) }
  let(:record) { create(:record, user: user) }

  shared_examples 'when not logged in' do
    it 'redirects to login_path' do
      do_request
      expect(response).to redirect_to login_path
    end
  end

  describe 'GET /records/:record_id/line_statuses/new #new' do
    let(:do_request) { get new_record_line_status_path(record), as: :turbo_stream }

    it_behaves_like 'when not logged in'

    it 'returns new modal when logged in' do
      log_in_as(user)
      do_request
      expect(response.body).to include '<h5 class="modal-title">行列の様子を報告</h5>'
    end

    context 'when logged in as other_user' do
      let(:other_user) { create(:user, :other_user) }

      before do
        log_in_as(other_user)
      end

      it 'has a flash notices incorrect user' do
        do_request
        expect(flash[:alert]).to eq '不正なアクセスです'
      end

      it 'redirects to root_path' do
        do_request
        expect(response).to redirect_to root_path
      end
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

    context 'when logged in as other_user' do
      let(:other_user) { create(:user, :other_user) }

      before do
        log_in_as(other_user)
      end

      it 'has a flash notices incorrect user' do
        do_request
        expect(flash[:alert]).to eq '不正なアクセスです'
      end

      it 'redirects to root_path' do
        do_request
        expect(response).to redirect_to root_path
      end
    end
  end
end
