require 'rails_helper'

RSpec.describe '/admin/announcements' do
  shared_examples 'when not logged in' do
    it 'redirects to login_path' do
      do_request
      expect(response).to redirect_to login_path
    end
  end

  shared_examples 'as a non-admin' do
    let!(:non_admin) { create(:user, :other_user) }

    it 'redirects to root_url' do
      log_in_as non_admin
      do_request
      expect(response).to redirect_to root_url
    end
  end

  describe 'GET /admin/announcements' do
    subject(:do_request) { get admin_announcements_path }

    let!(:admin) { create(:user, :admin) }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    context 'with admin' do
      before { log_in_as admin }

      it 'renders a successful response' do
        do_request
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /admin/announcements/new' do
    subject(:do_request) { get new_admin_announcement_path }

    let!(:admin) { create(:user, :admin) }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    context 'with admin' do
      before { log_in_as admin }

      it 'renders a successful response' do
        do_request
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /admin/announcements/:id' do
    subject(:do_request) { get admin_announcement_path(announcement) }

    let!(:announcement) { create(:announcement) }
    let!(:admin) { create(:user, :admin) }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    context 'with admin' do
      before { log_in_as admin }

      it 'renders a successful response' do
        do_request
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /admin/announcements/:id/edit' do
    subject(:do_request) { get edit_admin_announcement_path(announcement) }

    let!(:announcement) { create(:announcement) }
    let!(:admin) { create(:user, :admin) }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    context 'with admin' do
      before { log_in_as admin }

      it 'renders a successful response' do
        do_request
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /admin/announcements' do
    subject(:do_request) { post admin_announcements_path, params: valid_attributes }

    let!(:admin) { create(:user, :admin) }
    let(:valid_attributes) do
      { announcement: { title: 'テストお知らせ', published_at: 1.hour.ago } }
    end

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    context 'with admin' do
      before { log_in_as admin }

      context 'with valid parameters' do
        it 'creates a new Announcement' do
          expect {
            do_request
          }.to change(Announcement, :count).by(1)
        end

        it 'redirects to the created announcement' do
          do_request
          expect(response).to redirect_to admin_announcement_path(Announcement.last)
        end
      end

      context 'with invalid parameters' do
        subject(:do_request) do
          post admin_announcements_path, params: { announcement: { title: '', published_at: nil } }
        end

        it 'does not create a new Announcement' do
          expect {
            do_request
          }.to_not change(Announcement, :count)
        end

        it 'renders a response with 422 status' do
          do_request
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe 'PATCH /admin/announcements/:id' do
    subject(:do_request) { patch admin_announcement_path(announcement), params: valid_attributes }

    let!(:announcement) { create(:announcement) }
    let!(:admin) { create(:user, :admin) }
    let(:valid_attributes) do
      { announcement: { title: '更新されたお知らせ', published_at: announcement.published_at } }
    end

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    context 'with admin' do
      before { log_in_as admin }

      context 'with valid parameters' do
        it 'updates the requested announcement' do
          do_request
          expect(announcement.reload.title).to eq '更新されたお知らせ'
        end

        it 'redirects to the announcement' do
          do_request
          expect(response).to redirect_to admin_announcement_path(announcement)
        end
      end

      context 'with invalid parameters' do
        subject(:do_request) do
          patch admin_announcement_path(announcement), params: { announcement: { title: '', published_at: nil } }
        end

        it 'renders a response with 422 status' do
          do_request
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe 'DELETE /admin/announcements/:id' do
    subject(:do_request) { delete admin_announcement_path(announcement) }

    let!(:announcement) { create(:announcement) }
    let!(:admin) { create(:user, :admin) }

    it_behaves_like 'when not logged in'
    it_behaves_like 'as a non-admin'

    context 'with admin' do
      before { log_in_as admin }

      it 'destroys the requested announcement' do
        expect {
          do_request
        }.to change(Announcement, :count).by(-1)
      end

      it 'redirects to the announcements list' do
        do_request
        expect(response).to redirect_to admin_announcements_path
      end
    end
  end
end
