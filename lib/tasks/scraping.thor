require 'thor'
require 'nokogiri'

class Scraping < Thor
  FILE_NAME = 'scraped_shops_data'.freeze
  DEF_SHEET_NAME = 'def'.freeze
  SHOP_SHEET_NAME = 'shops'.freeze

  desc 'scrape_ramen_shops', '各ラーメン店へアクセスして店の情報を取得する'
  option :limit, type: :numeric, default: 10, desc: '取得するラーメン店の最大数'
  option :resume, type: :boolean, default: true, desc: '前回の続きからスクレイピングを再開'
  option :wait_seconds, type: :numeric, default: 60

  def scrape_ramen_shops
    initialize_scraping
    loop do
      break if reached_limit?

      process_current_target_url
      update_target_url
    end
  end

  desc 'execute SHOP_URL', 'スクレイピングしてユニークなShopをインサート・CSV出力'

  def execute(shop_url)
    document = DocumentFetcher.fetch_document_from_url(shop_url)
    return unless document

    shop_infos = ShopInfoExtractor.extract_shop_info(document)
    valid_shop_info = ShopInfoInserter.insert_unique_shops(shop_infos)
    return unless valid_shop_info.any?

    @sheet ||= fetch_sheet
    @sheet.append_shop_info(valid_shop_info)
  end

  private

  def fetch_sheet(resume_option: options[:resume])
    session = GcpSessionManager.new_session
    GoogleSpreadSheet.new(session: session, file_name: FILE_NAME, def_sheet_name: DEF_SHEET_NAME,
                          shops_sheet_name: SHOP_SHEET_NAME, resume_option: resume_option)
  end

  def initialize_scraping
    @sheet = fetch_sheet(resume_option: options[:resume])
    @target_url = @sheet.target_url
    @current_page = DocumentFetcher.fetch_document_from_url(@target_url)
    @shops_count = 0
  end

  def reached_limit?
    @shops_count >= options[:limit]
  end

  def process_current_target_url
    shop_links = filter_shop_links
    process_shop_links(shop_links)
  end

  def filter_shop_links
    shop_links = ShopInfoExtractor.extract_shop_links(@current_page)
    return shop_links unless options[:resume] && @sheet.last_page_present?

    retrieve_remaining_shop_links(shop_links)
  end

  def retrieve_remaining_shop_links(shop_links)
    last_link = @sheet.last_shop_url
    start_index = shop_links.index(last_link)

    if start_index
      shop_links[start_index + 1..]
    else
      puts 'Continuing from the beginning of the next page.'
      shop_links
    end
  end

  def process_shop_links(shop_links)
    shop_links.each do |link|
      break if reached_limit?

      process_shop_link(link)
      @shops_count += 1
    end
  end

  def process_shop_link(link)
    sleep options[:wait_seconds]
    shop_url = UrlManager.build_url(link)
    execute(shop_url)
    @sheet.save_last_shop_url(link)
  end

  def update_target_url
    next_link = next_page_link
    return unless next_link

    @sheet.save_target_url(@target_url)
    @target_url = UrlManager.build_url(next_link)
    @current_page = DocumentFetcher.fetch_document_from_url(@target_url)
  end

  def next_page_link
    next_link_node = @current_page.at_xpath('//div[@class="pages"]/a[@class="next"]/@onclick')
    return unless next_link_node

    match = next_link_node.value.match(/window.location.href='(.*?)'/)
    match[1] if match
  end
end
