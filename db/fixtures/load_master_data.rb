require "csv"
IMPORTS_PATH = "db/imports/import_2023-07-15_ramen_shops.csv"

def load_csv(file_path)
  CSV.read(file_path, headers: true).map(&:to_hash).map(&:symbolize_keys)
end

ramen_shops = load_csv IMPORTS_PATH

RamenShop.seed(:id, ramen_shops)
