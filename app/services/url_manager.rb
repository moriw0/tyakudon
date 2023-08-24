class UrlManager
  BASE_URL = 'https://ramendb.supleks.jp'.freeze
  LAST_PAGE_FILE = 'lib/tasks/last_page.txt'.freeze
  LAST_LINK_FILE = 'lib/tasks/last_link.txt'.freeze

  class << self
    def retrieve_last_shop_url
      File.read(LAST_LINK_FILE).chomp
    end

    def save_last_link(link)
      File.write(LAST_LINK_FILE, link)
    end

    def build_url(path)
      BASE_URL + path
    end
  end

  def initialize(resume_option)
    @resume_option = resume_option
  end

  def retrieve_target_url
    return File.read(LAST_PAGE_FILE).chomp if @resume_option && File.exist?(LAST_PAGE_FILE)

    "#{BASE_URL}/rank"
  end

  def save_last_page(target_url)
    File.write(LAST_PAGE_FILE, target_url)
  end
end
