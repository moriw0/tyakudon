require 'rails_helper'

RSpec.describe 'Likes' do
  describe 'POST /likes #create' do
    let!(:other_user) { create(:other_user) }
    let!(:record) { create(:record, user: other_user) }

    context 'when not logged in' do
      it 'redirects to login_path' do
        post likes_path, params: { record_id: record.id }, as: :turbo_stream
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in' do
      let!(:user) { create(:user) }

      before do
        log_in_as user
      end

      it 'adds like to record with Hotwire' do
        expect {
          post likes_path, params: { record_id: record.id }, as: :turbo_stream
        }.to change(Like, :count).by(1)
      end
    end
  end

  describe 'DELETE /likes/:id #destory' do
    let!(:user) { create(:user) }
    let!(:record) { create(:record, user: other_user) }
    let!(:other_user) { create(:other_user) }
    let!(:like) { create(:like, user: user, record: record) }

    context 'when not logged in' do
      it 'redirects to login_path' do
        delete like_path(like), as: :turbo_stream
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in' do
      before do
        log_in_as user
      end

      it 'remove like from record with Hotwire' do
        expect {
          delete like_path(like), as: :turbo_stream
        }.to change(Like, :count).by(-1)
      end
    end
  end
end
