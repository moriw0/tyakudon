require 'rails_helper'

RSpec.describe 'Favorites' do
  describe 'favorite_shops page' do
    let!(:user) { create(:user) }
    let!(:ramen_shops) { create_list(:many_shops, 5) }

    before do
      ramen_shops.each do |ramen_shop|
        create(:favorite, user: user, ramen_shop: ramen_shop)
      end
      log_in_as(user)
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
      let!(:ramen_shops) { create_list(:many_shops, 5) }

      before do
        log_in_as user
        ramen_shops.each do |ramen_shop|
          create(:favorite, user: user, ramen_shop: ramen_shop)
        end
      end

      context 'with no records' do
        it 'shows there is no records' do
          visit favorite_records_path
          expect(page).to have_content 'まだお気に入り店のちゃくどんがありません'
        end
      end

      context 'with favorite shop records' do
        let!(:other_user) { create(:other_user) }

        before do
          user.favorite_shops.each do |shop|
            create(:record, :with_line_status, ramen_shop: shop, user: other_user)
          end
        end

        it 'shows favorite shop record links' do
          visit favorite_records_path

          Record.favorite_records_from(user) do |record|
            expect(page).to have_link href: record_path(record)
          end
        end
      end
    end
  end
end
