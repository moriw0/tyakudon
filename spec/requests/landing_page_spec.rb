require 'rails_helper'

RSpec.describe 'LandingPages' do
  describe 'GET /index' do
    before { create(:record) }

    it 'returns http success' do
      get '/lp'
      expect(response).to have_http_status(:success)
    end
  end
end
