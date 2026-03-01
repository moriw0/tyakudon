require 'rails_helper'

RSpec.describe '/announcements' do
  describe 'GET /announcements' do
    context 'when logged in' do
      let!(:user) { create(:user) }

      before do
        create(:announcement)
        log_in_as user
      end

      it 'returns 200' do
        get announcements_path
        expect(response).to be_successful
      end

      it 'updates last_read_announcement_at' do
        expect {
          get announcements_path
        }.to change { user.reload.last_read_announcement_at }.from(nil)
      end

      it 'does not include draft announcements' do
        draft = create(:announcement, :draft)
        get announcements_path
        expect(response.body).to_not include(draft.title)
      end
    end

    context 'when not logged in' do
      let!(:published) { create(:announcement) }

      it 'returns 200' do
        get announcements_path
        expect(response).to be_successful
      end

      it 'does not update last_read_announcement_at' do
        expect {
          get announcements_path
        }.to_not(change { published.reload.updated_at })
      end
    end
  end

  describe 'GET /announcements/:id' do
    context 'with a published announcement' do
      let!(:announcement) { create(:announcement) }

      it 'returns 200' do
        get announcement_path(announcement)
        expect(response).to be_successful
      end
    end

    context 'with a draft announcement' do
      let!(:draft) { create(:announcement, :draft) }

      it 'returns 404' do
        get announcement_path(draft)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
