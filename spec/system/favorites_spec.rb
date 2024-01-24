require 'rails_helper'

RSpec.describe 'Favorites' do
  describe 'favorite_shops page' do
    let!(:user) { create(:user) }

    # rubocop:disable Rails/SkipsModelValidations
    before do
      log_in_as(user)

      ramen_shops = build_stubbed_list(:ramen_shop, 5, :many_shops)
      favorites = ramen_shops.map { |shop| build_stubbed(:favorite, user: user, ramen_shop: shop) }

      RamenShop.insert_all ramen_shops.map(&:attributes)
      Favorite.insert_all favorites.map(&:attributes)
    end

    it 'shows user favorite shops' do
      visit favorites_by_user_path(user)
      expect(page).to have_content '5 お気に入り店'
      user.favorite_shops.each do |shop|
        expect(page).to have_link href: ramen_shop_path(shop)
      end
    end
  end

  describe 'favorite_records page' do
    context 'when not logged in' do
      it 'shows there is no favorites' do
        visit favorite_records_path
        expect(page).to have_content 'まだお気に入り店の登録がありません'
      end
    end

    context ['when logged in', 'with no-favorite shop'].join(', ') do
      let!(:user) { create(:user) }

      before { log_in_as user }

      it 'shows there is no favorites' do
        visit favorite_records_path
        expect(page).to have_content 'まだお気に入り店の登録がありません'
      end
    end

    context ['when logged in', 'with favorite shop'].join(', ') do
      let!(:user) { create(:user) }

      before do
        log_in_as user

        ramen_shops = build_stubbed_list(:ramen_shop, 5, :many_shops)
        favorites = ramen_shops.map { |shop| build_stubbed(:favorite, user: user, ramen_shop: shop) }

        RamenShop.insert_all ramen_shops.map(&:attributes)
        Favorite.insert_all favorites.map(&:attributes)
      end

      context 'with no records' do
        it 'shows there is no records' do
          visit favorite_records_path
          expect(page).to have_content 'まだお気に入り店のちゃくどんがありません'
        end
      end

      context 'with favorite shop records' do
        let!(:other_user) { create(:user, :other_user) }

        before do
          records = user.favorite_shops.map { |shop| build_stubbed(:record, user: other_user, ramen_shop: shop) }
          line_statuses = records.map { |record| build_stubbed(:line_status, record: record) }

          Record.insert_all records.map(&:attributes)
          LineStatus.insert_all line_statuses.map(&:attributes)
        end
        # rubocop:enable Rails/SkipsModelValidations

        it 'shows favorite shop record links' do
          visit favorite_records_path

          Record.favorite_records_from(user) do |record|
            expect(page).to have_link href: record_path(record)
          end
        end

        it 'retrieves records that user selected', js: true do
          visit favorite_records_path

          favorite_shops = user.favorite_shops
          click_link "#{favorite_shops.size}店舗から絞り込む"
          favorite_shops.each do |shop|
            expect(page).to have_checked_field(shop.name)
          end

          uncheck '全て'
          favorite_shops.each do |shop|
            expect(page).to_not have_checked_field(shop.name)
          end

          check favorite_shops.last.name
          click_button '適用する'
          expect(page).to have_link '1店舗選択中'

          checked_last_shop_id = favorite_shops.last.id
          Record.filter_by_shop_ids(checked_last_shop_id) do |record|
            expect(page).to have_link href: record_path(record)
          end

          unchecked_shop_ids = favorite_shops.ids.reject { |id| id == checked_last_shop_id }
          Record.filter_by_shop_ids(unchecked_shop_ids) do |record|
            expect(page).to_not have_link href: record_path(record)
          end
        end
      end
    end
  end
end
