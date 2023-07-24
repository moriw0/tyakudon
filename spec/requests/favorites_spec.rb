require 'rails_helper'

RSpec.describe "Favorites", type: :request do
  let(:favorite) { create(:favorite) }

  describe 'POST /favorites #create' do
    context 'when not logged in' do
      it 'redirects to login_path' do
        post favorites_path
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'DELETE /favorites/:id #destory' do
    context 'when not logged in' do
      it 'redirects to login_path' do
        delete favorite_path(favorite)
        expect(response).to redirect_to login_path
      end
    end
  end
end
