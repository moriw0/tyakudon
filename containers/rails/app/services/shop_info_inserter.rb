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

    def append_shop_info_to_csv(csv_path, valid_shop_info, last_id = nil)
      last_id ||= last_id_from_csv(csv_path)
      CSV.open(csv_path, 'a') do |csv|
        valid_shop_info.each_with_index do |info, index|
          csv << [last_id + index + 1, *info]
        end
      end
    end

    def last_id_from_csv(file_name)
      last_line = CSV.readlines(file_name).last
      return 0 unless last_line

      last_line.first.to_i
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
