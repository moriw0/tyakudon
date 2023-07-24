require 'rails_helper'

RSpec.describe "Favorites", type: :request do
  let(:user) { create(:user) }
  let(:ramen_shop) { create(:ramen_shop) }

  describe 'POST /favorites #create' do
    context 'when not logged in' do
      it 'redirects to login_path' do
        post favorites_path
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in' do
      before do
        log_in_as user
      end

      it 'adds shop to favorite the standard way' do
        expect {
          post favorites_path, params: { ramen_shop_id: ramen_shop.id }
        }.to change(Favorite, :count).by(1)
      end

      it 'adds shop to favorite with Hotwire' do
        expect {
          post favorites_path, params: { ramen_shop_id: ramen_shop.id }, as: :turbo_stream
        }.to change(Favorite, :count).by(1)
      end
    end
  end

  describe 'DELETE /favorites/:id #destory' do
    let!(:favorite) { create(:favorite, user: user, ramen_shop: ramen_shop) }

    context 'when not logged in' do
      it 'redirects to login_path' do
        delete favorite_path(favorite)
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in' do
      before do
        log_in_as user
      end

      it 'remove shop from favorite the standard way' do
        expect {
          delete favorite_path(favorite)
        }.to change(Favorite, :count).by(-1)
      end

      it 'remove shop from favorite with Hotwire' do
        expect {
          delete favorite_path(favorite)
        }.to change(Favorite, :count).by(-1)
      end
    end
  end
end
