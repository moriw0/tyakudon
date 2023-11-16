class ShopInfoInserter
  class << self
    # rubocop:disable Rails/Output
    def insert_unique_shops(shop_infos)
      shop_infos.each_with_object([]) do |info, unique_shops|
        shop_name, _, _, full_address, = info

        if shop_already_exists?(shop_name, full_address)
          puts "'#{shop_name}' already exists."
        else
          insert_shop(shop_name, full_address, info, unique_shops)
        end
      end
    end

    private

    def shop_already_exists?(shop_name, full_address)
      RamenShop.exists?(name: shop_name, address: full_address)
    end

    def insert_shop(shop_name, full_address, info, unique_shops)
      RamenShop.create(name: shop_name, address: full_address)
      unique_shops << info
      puts "'#{shop_name}' was inserted."
    end
    # rubocop:enable Rails/Output
  end
end
