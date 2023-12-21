require 'rails_helper'

RSpec.describe 'FavoriteRecords' do
  # rubocop:disable Rails/SkipsModelValidations
  describe 'GET /index' do
    context ['when user is logged in', 'has favorite shops'].join(', ') do
      let!(:user) { create(:user) }
      let!(:ramen_shops) { build_stubbed_list(:ramen_shop, 3, :many_shops) }
      let!(:favorites) do
        ramen_shops.first(2).map { |shop| build_stubbed(:favorite, ramen_shop: shop, user: user) }
      end

      before do
        log_in_as user
        RamenShop.insert_all ramen_shops.map(&:attributes)
        Favorite.insert_all favorites.map(&:attributes)
      end

      context 'when ids are provided' do
        it 'sets @checked_ids based on provided ids' do
          get favorite_records_path, params: { shop_ids: [ramen_shops.first.id] }
          expect(controller.instance_variable_get(:@checked_ids)).to eq([ramen_shops.first.id])
        end
      end

      context 'when ids are not provided' do
        it 'sets @checked_ids based on user favorite shop ids' do
          get favorite_records_path
          expect(controller.instance_variable_get(:@checked_ids)).to eq(user.favorite_shop_ids)
        end
      end
    end

    context 'when user is not logged in' do
      it 'shows no records messages' do
        get favorite_records_path
        expect(response.body).to include '<h3>まだお気に入り店の登録がありません</h3>'
      end
    end
  end

  describe 'GET /filter' do
    context ['when user is logged in', 'has favorite shops'].join(', ') do
      let!(:user) { create(:user) }
      let!(:ramen_shops) { build_stubbed_list(:ramen_shop, 3, :many_shops) }
      let!(:favorites) do
        ramen_shops.first(2).map { |shop| build_stubbed(:favorite, ramen_shop: shop, user: user) }
      end

      before do
        log_in_as user
        RamenShop.insert_all ramen_shops.map(&:attributes)
        Favorite.insert_all favorites.map(&:attributes)
      end

      context 'when ids are provided' do
        it 'sets @checked_ids based on provided ids' do
          get filter_favorite_records_path, params: { shop_ids: [ramen_shops.first.id] }, as: :turbo_stream
          expect(controller.instance_variable_get(:@checked_ids)).to eq [ramen_shops.first.id]
        end
      end

      context 'when ids are not provided' do
        it 'sets @checked_ids based on user favorite shop ids' do
          get filter_favorite_records_path, as: :turbo_stream
          expect(controller.instance_variable_get(:@checked_ids)).to eq user.favorite_shop_ids
        end
      end
    end

    context 'when user is not logged in' do
      it 'sets @checked_ids as nil' do
        get filter_favorite_records_path, as: :turbo_stream
        expect(response).to redirect_to login_path
      end
    end
  end
  # rubocop:enable Rails/SkipsModelValidations
end
