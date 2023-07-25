require 'rails_helper'

RSpec.describe 'Records' do
  let(:ramen_shop) { create(:ramen_shop) }
  let(:user) { create(:user) }
  let(:record) { create(:record, ramen_shop: ramen_shop, user: user) }

  shared_examples 'when not logged in' do
    it 'redirects to login_path' do
      do_request
      expect(response).to redirect_to login_path
    end
  end

  describe 'GET /ramen_shops/:ramen_shop_id/records/new #new' do
    let(:do_request) { get new_ramen_shop_record_path(ramen_shop), as: :turbo_stream }

    it_behaves_like 'when not logged in'

    it 'returns new modal when logged in' do
      log_in_as(user)
      do_request
      expect(response.body).to include '<h5 class="modal-title">接続</h5>'
    end
  end

  describe 'POST /ramen_shops/:ramen_shop_id/records #create' do
    let(:do_request) { post ramen_shop_records_path(ramen_shop), params: record_params_without_record }
    let(:record) { controller.instance_variable_get(:@record) }
    let(:record_params_without_record) do
      { record: {
        ramen_shop_id: ramen_shop.id,
        user_id: user.id,
        started_at: nil,
        line_statuses_attributes: [
          line_number: 1,
          line_type: 'inside_the_store',
          comment: '並ぶぞ'
        ]
      } }
    end

    it_behaves_like 'when not logged in'

    context 'when logged in' do
      before do
        log_in_as(user)
      end

      context 'with valid information' do
        it 'updates started_at when logged in' do
          log_in_as(user)
          do_request
          expect(record.started_at).to_not be_nil
        end

        it 'redirects to measure_record_path' do
          do_request
          expect(response).to redirect_to measure_record_path(record)
        end
      end

      context 'with invalid information' do
        it 'shows validation errors' do
          record_params_without_record[:record][:line_statuses_attributes][0][:line_number] = -1
          post ramen_shop_records_path(ramen_shop), params: record_params_without_record, as: :turbo_stream
          expect(response.body).to include 'は0以上の値にしてください'
        end
      end
    end
  end

  describe 'GET /records/:id/edit #edit' do
    let(:do_request) { get edit_record_path(record) }

    it_behaves_like 'when not logged in'
  end

  describe 'GET /records/:id/measure #measure' do
    let(:do_request) { get measure_record_path(record) }

    it_behaves_like 'when not logged in'

    context 'when logged in' do
      context 'when the record.ended_at? is true' do
        it 'redirects to root_path' do
          log_in_as(user)
          do_request
          expect(response).to redirect_to root_path
        end
      end
    end
  end


  describe 'GET /records/:id/calculate #calculate' do
    let(:do_request) { patch calculate_record_path(record) }

    it_behaves_like 'when not logged in'

    context 'when logged in' do
      before do
        log_in_as(user)
      end

      it 'updates wait_time' do
        record.update(ended_at: nil, wait_time: nil)
        do_request
        expect(record.reload.wait_time).to_not be_nil
      end

      it 'redirects to root_path if ended' do
        record.update(ended_at: Time.now)
        do_request
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'GET /records/:id/result #result' do
    let(:do_request) { get result_record_path(record) }

    it_behaves_like 'when not logged in'

    context 'when logged in' do
      before do
        log_in_as(user)
      end

      it 'has the wait_time in response body' do
        do_request
        expect(response.body).to include '着丼してひとこと'
      end
    end
  end

  describe 'PATCH /records/:id #update' do
    let(:do_request) { patch record_path(record), params: record_params }
    let(:record_params) { { record: { comment: 'ちゃくどん' } } }

    it_behaves_like 'when not logged in'

    context 'when logged in' do
      before do
        log_in_as(user)
      end

      it 'updates comment' do
        record.update(comment: nil)
        do_request
        expect(record.reload.comment).to include 'ちゃくどん'
      end

      it 'redirects to record_path' do
        do_request
        expect(response).to redirect_to record_path(record)
      end

      it 'shows error message with long comment' do
        invalid_record_params = { record: { comment: 'a' * 141 } }
        patch record_path(record), params: invalid_record_params
        expect(response.body).to include 'は140文字以内で入力してください'
      end
    end
  end
end
