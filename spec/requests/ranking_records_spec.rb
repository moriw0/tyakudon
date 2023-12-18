require 'rails_helper'

RSpec.describe 'RankingRecords' do
  describe 'GET /index' do
    it 'returns http success' do
      get '/ranking'
      expect(response).to have_http_status(:success)
    end
  end
end
