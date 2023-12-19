require 'rails_helper'

RSpec.describe 'FavoriteRecords' do
  describe 'GET /index' do
    it 'returns http success' do
      get '/favorite_records/index'
      expect(response).to have_http_status(:success)
    end
  end
end
