class DocumentFetcher
  # rubocop:disable Rails/Output
  def self.fetch_document_from_url(url)
    html_content = URI.parse(url).read
    Nokogiri::HTML(html_content)
  rescue OpenURI::HTTPError => e
    puts "Error fetching document: #{e.message}"
    puts "URL: #{url}"
    nil
  end
  # rubocop:enable Rails/Output
end
