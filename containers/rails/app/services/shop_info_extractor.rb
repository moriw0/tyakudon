class ShopInfoExtractor
  class << self
    def extract_shop_links(document)
      document.xpath('//div[@class="ranks"]//table[@class="rank"]//span[@class="name"]/a/@href').map(&:text)
    end

    def extract_shop_info(document)
      document.xpath('//*[@id="shop-data-table"]').map do |node|
        extract_individual_shop_info(node)
      end
    end

    private

    def extract_individual_shop_info(node)
      shop_name = extract_text(node, '//th[text()="店名"]/following-sibling::td')
      prefecture, city, full_address = extract_address_info(node)
      operation_hours = extract_text(node, '//th[text()="営業時間"]/following-sibling::td')
      closing_days = extract_text(node, '//th[text()="定休日"]/following-sibling::td')
      today = Time.zone.today

      [shop_name, prefecture, city, full_address, operation_hours, closing_days, today]
    end

    def extract_address_info(node)
      address_node = node.at_xpath('//th[text()="住所"]/following-sibling::td/span')
      prefecture = address_node.at_xpath('a[1]').text
      city = address_node.at_xpath('a[2]').text
      full_address = normalize_full_address(address_node.text)

      [prefecture, city, full_address]
    end

    def normalize_full_address(address)
      address.gsub(/〒\d+-\d+ /, '').gsub(/このお店は「.+」から移転しました。/, '')
    end

    def extract_text(node, xpath)
      node.xpath(xpath).text.strip
    end
  end
end
