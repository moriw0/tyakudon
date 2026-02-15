require 'rails_helper'

RSpec.describe 'Statics' do
  describe 'GET /terms #terms' do
    it 'returns 200 OK without login' do
      get terms_path
      expect(response).to have_http_status(:ok)
    end

    it 'returns 200 OK when logged in' do
      user = create(:user)
      log_in_as user
      get terms_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /privacy_policy #privacy_policy' do
    it 'returns 200 OK without login' do
      get privacy_policy_path
      expect(response).to have_http_status(:ok)
    end

    it 'returns 200 OK when logged in' do
      user = create(:user)
      log_in_as user
      get privacy_policy_path
      expect(response).to have_http_status(:ok)
    end
  end
end
