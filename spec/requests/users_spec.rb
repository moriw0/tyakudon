require 'rails_helper'

RSpec.describe 'Users' do
  describe 'GET /new' do
    it 'returns http success' do
      get signup_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /users #create' do
    it 'user cannot create account with invalid information' do
      expect {
        post users_path, params: { user: { name: '',
                                           email: 'user@invalid',
                                           password: 'foo',
                                           password_confirmation: 'bar' } }
      }.to_not change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
