require 'rails_helper'

RSpec.describe 'RamenShops' do
  describe 'GET /index' do
    it 'returns http success' do
      get '/ramen_shops/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      get '/ramen_shops/show'
      expect(response).to have_http_status(:success)
    end
  end
end
