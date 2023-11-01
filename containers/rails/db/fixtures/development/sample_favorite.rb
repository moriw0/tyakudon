ramen_shops = RamenShop.take(20)

user = User.first
user_favorite_shops = ramen_shops[0..14]

id = 0
favorites = user_favorite_shops.map do |shop|
  {
    id: id += 1,
    user: user,
    ramen_shop: shop,
  }
end

other_user = User.second
other_user_favorite_shops = ramen_shops[5..19]

favorites += other_user_favorite_shops.map do |shop|
  {
    id: id += 1,
    user: other_user,
    ramen_shop: shop,
  }
end

Favorite.seed(:id, favorites)
