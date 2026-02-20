class AddVisibleRecordsCountToRamenShops < ActiveRecord::Migration[7.1]
  def up
    add_column :ramen_shops, :visible_records_count, :integer, null: false, default: 0

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

    add_index :records,
              %i[ramen_shop_id auto_retired is_test],
              name: 'index_records_on_shop_and_active_conditions',
              where: 'wait_time IS NOT NULL'
  end

  def down
    remove_index :records, name: 'index_records_on_shop_and_active_conditions'
    remove_column :ramen_shops, :visible_records_count
  end
end
