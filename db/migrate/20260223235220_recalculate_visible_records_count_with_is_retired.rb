class RecalculateVisibleRecordsCountWithIsRetired < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      UPDATE ramen_shops
      SET visible_records_count = (
        SELECT COUNT(*) FROM records
        WHERE records.ramen_shop_id = ramen_shops.id
          AND records.auto_retired = false
          AND records.is_retired = false
          AND records.is_test = false
          AND records.wait_time IS NOT NULL
      )
    SQL
  end

  def down
    execute <<~SQL
      UPDATE ramen_shops
      SET visible_records_count = (
        SELECT COUNT(*) FROM records
        WHERE records.ramen_shop_id = ramen_shops.id
          AND records.auto_retired = false
          AND records.is_test = false
          AND records.wait_time IS NOT NULL
      )
    SQL
  end
end
