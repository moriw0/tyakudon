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

  describe 'POST /users #create' do
    it 'cannot create account with invalid information' do
      expect {
        post users_path, params: { user: { name: '',
                                           email: 'user@invalid',
                                           password: 'foo',
                                           password_confirmation: 'bar' } }
      }.to_not change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'creats account with valid information' do
      expect {
        post users_path, params: { user: { name: 'user',
                                           email: 'user@examle.com',
                                           password: 'foobar',
                                           password_confirmation: 'foobar' } }
        expect(is_logged_in?).to be_truthy
      }.to change(User, :count).by(1)
    end
  end

  describe 'EDIT /user/:id' do
    let(:user) { create(:user) }
    let(:other_user) { create(:other_user) }

    it 'redirects to login_path when not logged_in' do
      get edit_user_path(user)
      expect(response).to redirect_to login_path
    end

    it 'redirects to login_path when not logged_in' do
      patch user_path(user), params: { user: { name: user.name,
                                               email: user.email } }
      expect(response).to redirect_to login_path
    end

    it 'redirects to root_url logged in as wrong user' do
      log_in_as(user)
      get edit_user_path(other_user)
      expect(response).to redirect_to root_url
    end

    it 'redirects to root_url logged in as wrong user' do
      log_in_as(user)
      patch user_path(other_user), params: { user: { name: user.name,
                                               email: user.email } }
      expect(response).to redirect_to root_url
    end

    it 'successfully edits with friendly forwarding' do
      get edit_user_path(user)
      log_in_as(user)
      expect(response).to redirect_to edit_user_path(user)
      name  = "Foo Bar"
      email = "foo@bar.com"
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

    it "does not allow the admin attribute to be edited via the web" do
      log_in_as(other_user)
      expect(other_user.admin?).to be_falsy
      patch user_path(other_user), params: {
                                      user: { password:              "password",
                                              password_confirmation: "password",
                                              admin: true } }
      expect(other_user.reload.admin?).to be_falsy
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
end
