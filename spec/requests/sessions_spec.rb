require 'rails_helper'

RSpec.describe 'Sessions' do
  describe 'GET /login #new' do
    it 'returns 200 OK for unauthenticated user' do
      get login_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /sessions #create' do
    let(:user) { create(:user) }

    context 'when standard login' do
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

      context 'when user is not activated' do
        let(:inactive_user) { create(:user, :not_activated) }

        it 'logs in successfully (activation not checked at session level)' do
          post login_path, params: { session: { email: inactive_user.email,
                                                password: inactive_user.password } }
          expect(is_logged_in?).to be_truthy
        end
      end
    end

    context 'when OAuth login with valid OAuth' do
      before do
        Rails.application.env_config['omniauth.auth'] = set_omniauth
      end

      after do
        Rails.application.env_config.delete('omniauth.auth')
      end

      context 'with first-time user' do
        it 'redirects to new_omniauth_user_path' do
          get '/auth/google_oauth2/callback'
          expect(response).to redirect_to new_omniauth_user_path
        end
      end

      context 'with existing OAuth user' do
        before do
          create(:user, provider: 'google_oauth2', uid: '123456')
        end

        it 'logins with existing user' do
          get '/auth/google_oauth2/callback'
          expect(is_logged_in?).to be_truthy
        end

        it 'has a notice flash' do
          get '/auth/google_oauth2/callback'
          expect(flash[:notice]).to eq 'ログインしました'
        end
      end

      context 'with exsting standard user' do
        before { create(:user, email: 'oauth@example.com') }

        it 'redirects to login page' do
          get '/auth/google_oauth2/callback'
          expect(response).to redirect_to(login_path)
        end

        it 'has a notice flash' do
          get '/auth/google_oauth2/callback'
          expect(flash[:notice]).to eq '既に登録されているメールアドレスです。ログインしてください。'
        end
      end
    end

    context 'when OAuth login with invalid OAuth' do
      before do
        create(:user, provider: 'google_oauth2', uid: '123456')
        Rails.application.env_config['omniauth.auth'] = set_invalid_omniauth
      end

      after do
        Rails.application.env_config.delete('omniauth.auth')
      end

      it 'is not logged in' do
        get '/auth/google_oauth2/callback'
        expect(is_logged_in?).to be_falsey
      end

      it 'redirects to root_path' do
        get '/auth/google_oauth2/callback'
        expect(response).to redirect_to root_path
      end

      it 'has a alert flash' do
        get '/auth/google_oauth2/callback'
        expect(flash[:alert]).to eq 'ログインに失敗しました'
      end
    end
  end
end
