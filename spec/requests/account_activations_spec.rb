require 'rails_helper'

RSpec.describe 'AccountActivations' do
  describe 'GET /account_activations/:id/edit #edit' do
    let(:user) { controller.instance_variable_get(:@user) }

    before do
      post users_path, params: { user: { name: 'example user',
                                         email: 'test@example.com',
                                         password: 'foobar',
                                         password_confirmation: 'foobar' } }
    end

    context 'with valid token and email' do
      it 'makes user be activated' do
        get edit_account_activation_path(user.activation_token, email: user.email)
        user.reload
        expect(user).to be_activated
      end

      it 'makes user be logged_in' do
        get edit_account_activation_path(user.activation_token, email: user.email)
        expect(is_logged_in?).to be_truthy
      end

      it 'redirects to user_path' do
        get edit_account_activation_path(user.activation_token, email: user.email)
        expect(response).to redirect_to user
      end
    end

    context 'with invalid information' do
      it 'does not make user be activated with invalid token' do
        get edit_account_activation_path('invalid token', email: user.email)
        user.reload
        expect(user).to_not be_activated
      end

      it 'does not make user be logged_in with invalid email' do
        get edit_account_activation_path(user.activation_token, email: 'invalid')
        expect(is_logged_in?).to be_falsy
      end
    end
  end
end
