class UrlManager
  BASE_URL = 'https://ramendb.supleks.jp'.freeze

  def self.build_url(path)
    BASE_URL + path
  end
end
