require 'rails_helper'

RSpec.describe 'Users' do
  describe 'GET /new' do
    it 'returns http success' do
      get signup_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /users' do
    it 'redirects index when not logged in' do
      get users_path
      expect(response).to redirect_to login_url
    end
  end

  describe 'GET /users/:id #show' do
    context 'with activated user' do
      it 'shows user page' do
        activated_user = create(:user)
        get user_path(activated_user)
        expect(response.body).to include(activated_user.name)
      end
    end

    context 'with non activated user' do
      it 'redirects to root_path' do
        non_activated_user = create(:non_activated_user)
        get user_path(non_activated_user)
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'POST /users #create' do
    context 'with invalid information' do
      it 'does not create an account' do
        expect {
          post users_path, params: { user: { name: '',
                                             email: 'user@invalid',
                                             password: 'foor',
                                             password_confirmation: 'bar' } }
        }.to_not change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with valid information' do
      let(:user_params) do
        { user: { name: 'user',
                  email: 'user@examle.com',
                  password: 'foobar',
                  password_confirmation: 'foobar' } }
      end

      before do
        ActionMailer::Base.deliveries.clear
      end

      it 'creats an account' do
        expect {
          post users_path, params: user_params
        }.to change(User, :count).by(1)
      end

      it 'is still not logged in' do
        post users_path, params: user_params
        expect(is_logged_in?).to be_falsy
      end

      it 'sends an email' do
        post users_path, params: user_params
        expect(ActionMailer::Base.deliveries.size).to eq 1
      end

      it 'is still not activated' do
        post users_path, params: user_params
        expect(User.last).to_not be_activated
      end
    end
  end

  describe 'GET /user/:id/edit' do
    let(:user) { create(:user) }
    let(:other_user) { create(:other_user) }

    it 'redirects to login_path when not logged_in' do
      get edit_user_path(user)
      expect(response).to redirect_to login_path
    end

    it 'redirects to root_url logged in as wrong user' do
      log_in_as(user)
      get edit_user_path(other_user)
      expect(response).to redirect_to root_url
    end

    it 'successfully edits with friendly forwarding' do
      get edit_user_path(user)
      log_in_as(user)
      expect(response).to redirect_to edit_user_path(user)
      name  = 'Foo Bar'
      email = 'foo@bar.com'
      patch user_path(user), params: { user: { name: name,
                                               email: email } }
      expect(response).to redirect_to user
      user.reload
      expect(user.name).to eq name
      expect(user.email).to eq email
    end
  end

  describe 'POST /user/:id' do
    let(:user) { create(:user) }
    let(:other_user) { create(:other_user) }

    it 'redirects to login_path when not logged_in' do
      patch user_path(user), params: { user: { name: user.name,
                                               email: user.email } }
      expect(response).to redirect_to login_path
    end

    it 'redirects to root_url logged in as wrong user' do
      log_in_as(user)
      patch user_path(other_user), params: { user: { name: user.name,
                                                     email: user.email } }
      expect(response).to redirect_to root_url
    end

    it 'does not allow the admin attribute to be edited via the web' do
      log_in_as(other_user)
      expect(other_user).to_not be_admin
      patch user_path(other_user), params: {
        user: { password: 'password',
                password_confirmation: 'password',
                admin: true }
      }
      expect(other_user.reload).to_not be_admin
    end
  end

  describe 'DELETE /user/:id' do
    let!(:user) { create(:user) }
    let(:other_user) { create(:other_user) }

    context 'when not logged in' do
      it 'cannot delete user' do
        expect {
          delete user_path(user)
        }.to_not change(User, :count)
      end

      it 'redirects to login_path' do
        delete user_path(user)
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as a non-admin' do
      before do
        log_in_as other_user
      end

      it 'cannot delete user' do
        expect {
          delete user_path(user)
        }.to_not change(User, :count)
      end

      it 'redirects to root_path' do
        delete user_path(user)
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'GET /user/:id/favorite_shops' do
    let(:user) { create(:user) }

    context 'when not logged in' do
      it 'redirects to login_path' do
        get favorites_by_user_path(user)
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'PATCH /users/:id/update_test_mode #update_test_mode' do
    let(:admin) { create(:user) }
    let(:other_user) { create(:other_user) }
    let(:do_request) { patch update_test_mode_user_path(other_user), params: { user: { is_test_mode: true } }, as: :turbo_stream }

    context 'when logged in as admin' do

      it 'updates test mode' do
        log_in_as admin
        do_request
        expect(other_user.reload.is_test_mode).to be_truthy
      end
    end

    context 'when not logged in' do
      it 'does not update test mode' do
        do_request
        expect(other_user.reload.is_test_mode).to be_falsy
      end

      it 'redirects to login path' do
        do_request
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as a non-admin' do
      before do
        log_in_as other_user
      end

      it 'does not update test mode' do
        do_request
        expect(other_user.reload.is_test_mode).to be_falsy
      end

      it 'redirects to root_path' do
        do_request
        expect(response).to redirect_to root_path
      end
    end
  end
end
