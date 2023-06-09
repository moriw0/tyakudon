require 'rails_helper'

RSpec.describe 'Sessions' do
  describe 'POST /sessions #create' do
    let(:user) { create(:user) }

    it 'cannot login with valid email and invalid password' do
      post login_path, params: { session: { email: user.email,
                                            password: 'invalid' } }
      expect(is_logged_in?).to_not be_truthy
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'logins with valid information follewd by logout' do
      post login_path, params: { session: { email: user.email,
                                            password: user.password } }
      expect(is_logged_in?).to be_truthy
      delete logout_path
      expect(is_logged_in?).to_not be_truthy
      expect(response).to have_http_status(:see_other)
      delete logout_path
      expect(response).to redirect_to root_path
    end

    context 'when user checks the Remember Me box' do
      it 'remembers the cookie' do
        log_in_as(user, remember_me: '1')
        expect(cookies[:remember_token]).to_not be_nil
      end
    end

    context 'when user does not checks the Remember Me box' do
      it 'does not remember the cookie' do
        log_in_as(user, remember_me: '0')
        expect(cookies[:remember_token]).to be_nil
      end
    end
  end
end
