require 'rails_helper'

RSpec.describe 'ShopRegisterRequests' do
  describe 'GET /new' do
    it 'returns http success' do
      get '/shop_register_requests/new'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /create' do
    it 'returns http success' do
      get '/shop_register_requests/create'
      expect(response).to have_http_status(:success)
    end
  end
end
