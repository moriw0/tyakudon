require 'rails_helper'

RSpec.describe 'PasswordResets' do
  describe 'POST /password_resets/ #post' do
    let(:user) { create(:user) }
    let(:user_params) { { password_reset: { email: user.email } } }

    context 'when the account exits' do
      before do
        ActionMailer::Base.deliveries.clear
      end

      it 'changes reset digest' do
        post password_resets_path, params: user_params
        expect(user.reset_digest).to_not eq user.reload.reset_digest
      end

      it 'sends an email' do
        post password_resets_path, params: user_params
        expect(ActionMailer::Base.deliveries.size).to eq 1
      end

      it 'redirects to root_path' do
        post password_resets_path, params: user_params
        expect(response).to redirect_to root_path
      end
    end

    context 'when the account is not found' do
      it 'return unprocessable_entity' do
        post password_resets_path, params: { password_reset: { email: 'invalid' } }
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'GET /password_resets/:id/edit #edit' do
    let(:user) { controller.instance_variable_get(:@user) }

    context 'with valid token and email' do
      it 'has hidden email field' do
        post password_resets_path, params: { password_reset: { email: create(:user).email } }
        get edit_password_reset_path(user.reset_token, email: user.email)
        expect(response.body).to include "type=\"hidden\" name=\"email\" id=\"email\" value=\"#{user.email}\""
      end
    end

    context 'with invalid information' do
      before do
        post password_resets_path, params: { password_reset: { email: create(:user).email } }
      end

      # rubocop:disable Rails/SkipsModelValidations
      it 'redirects to root_path when user does not activated' do
        user.toggle!(:activated)
        get edit_password_reset_path(user.reset_token, email: user.email)
        expect(response).to redirect_to root_path
      end
      # rubocop:enable Rails/SkipsModelValidations

      it 'redirects to root_path with invalid token' do
        get edit_password_reset_path('invalid token', email: user.email)
        expect(response).to redirect_to root_path
      end

      context 'when reset_sent_at is expired' do
        before do
          user.update(reset_sent_at: 3.hours.ago)
        end

        it 'redirects to new_password_reset_path' do
          get edit_password_reset_path(user.reset_token, email: user.email)
          expect(response).to redirect_to new_password_reset_path
        end

        it 'shows flash suggesting expired' do
          get edit_password_reset_path(user.reset_token, email: user.email)
          follow_redirect!
          expect(response.body).to include 'パスワードリセット用URLの有効期限が切れています'
        end
      end
    end
  end

  describe 'PATCH /password_resets/:id #update' do
    let(:user) { controller.instance_variable_get(:@user) }

    before do
      post password_resets_path, params: { password_reset: { email: create(:user).email } }
    end

    context 'with valid password' do
      let(:user_params) { { user: { password: 'foobar', password_confirmation: 'foobar' } } }

      it 'updates password' do
        patch password_reset_path(user.reset_token, email: user.email), params: user_params
        expect(user.password_digest).to_not eq user.reload.password_digest
      end

      it 'makes user be logged in' do
        patch password_reset_path(user.reset_token, email: user.email), params: user_params
        expect(is_logged_in?).to be_truthy
      end

      it 'redirects to user_path' do
        patch password_reset_path(user.reset_token, email: user.email), params: user_params
        expect(response).to redirect_to user_path(user)
      end

      it 'updates reset_digest to nil' do
        patch password_reset_path(user.reset_token, email: user.email), params: user_params
        expect(user.reload.reset_digest).to be_nil
      end
    end

    context 'with invalid password' do
      it 'does not update password with blank password' do
        patch password_reset_path(user.reset_token, email: user.email),
              params: { user: { password: '', password_confirmation: '' } }
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'does not update password with invalid password' do
        patch password_reset_path(user.reset_token, email: user.email),
              params: { user: { password: 'foo', password_confirmation: 'bar' } }
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
