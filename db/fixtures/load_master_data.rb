require "csv"
IMPORTS_PATH = "db/imports/import_2023-07-15_ramen_shops.csv"

def load_csv(file_path)
  CSV.read(file_path, headers: true, liberal_parsing: true).map(&:to_hash).map(&:symbolize_keys)
end

ramen_shops = load_csv IMPORTS_PATH

ramen_shops.each do |shop|
  RamenShop.find_or_create_by!(shop)
end

FAQ_IMPORTS_PATH = "db/imports/import_2024-06-10_faqs.csv"

faqs = load_csv FAQ_IMPORTS_PATH

faqs.each do |faq|
  created_faq = Faq.find_or_create_by!(
    question: faq[:question],
    answer: faq[:answer]
  )
  ActionText::RichText.find_or_create_by!(
    record_type: 'Faq',
    record_id: created_faq.id,
    name: 'detail',
    body: faq[:detail]
  )
end
