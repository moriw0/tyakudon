class GoogleSpreadSheet
  attr_accessor :def_sheet, :shops_sheet
  attr_reader :resume_option

  def initialize(session:, file_name:, def_sheet_name:, shops_sheet_name:, resume_option: nil)
    spreadsheet = session.spreadsheet_by_title(file_name)
    @def_sheet = spreadsheet.worksheet_by_title(def_sheet_name)
    @shops_sheet = spreadsheet.worksheet_by_title(shops_sheet_name)
    @resume_option = resume_option
  end

  def last_shop_url
    @def_sheet[2, 2]
  end

  def save_last_shop_url(link)
    update_def_sheet_cell(2, 2, link)
  end

  def target_url
    return @def_sheet[2, 1] if @resume_option && last_page_present?

    "#{UrlManager::BASE_URL}/rank"
  end

  def save_target_url(url)
    update_def_sheet_cell(2, 1, url)
  end

  def last_page_present?
    @def_sheet[2, 1].present?
  end

  def append_shop_info(valid_shop_info)
    last_id = fetch_last_id
    insert_data = [[last_id + 1, *valid_shop_info.first]]
    @shops_sheet.insert_rows(@shops_sheet.num_rows + 1, insert_data)
    @shops_sheet.save
  end

  private

  def fetch_last_id
    last_row = @shops_sheet.rows.last
    last_row ? last_row.first.to_i : 0
  end

  def update_def_sheet_cell(row, col, value)
    @def_sheet[row, col] = value
    @def_sheet.save
  rescue StandardError => e
    Rails.logger.debug { "Error updating spreadsheet: #{e.message}" }
  end
end
