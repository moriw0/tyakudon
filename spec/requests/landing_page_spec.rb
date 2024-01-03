require 'rails_helper'

RSpec.describe 'LandingPages' do
  describe 'GET /index' do
    it 'returns http success' do
      get '/landing_page/index'
      expect(response).to have_http_status(:success)
    end
  end
end
