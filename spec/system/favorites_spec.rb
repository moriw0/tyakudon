require 'rails_helper'

RSpec.describe "Favorites", type: :system do
  let(:user) { create(:user) }
  let(:ramen_shops) { create_list(:ramen_shop, 5) }

  before do
    ramen_shops.each do |ramen_shop|
      create(:favorite, user: user, ramen_shop: ramen_shop)
    end
    log_in_as(user)
  end

  scenario "favorite_shops_page" do
    visit favorites_by_user_path(user)
    expect(page).to have_content 'お気に入り店 5'
    user.favorite_shops.each do |shop|
      expect(page).to have_link 'みてみる', href: ramen_shop_path(shop)
    end
  end
end
