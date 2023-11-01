class DocumentFetcher
  def self.fetch_document_from_url(url)
    html_content = URI.parse(url).read
    Nokogiri::HTML(html_content)
  end
end
