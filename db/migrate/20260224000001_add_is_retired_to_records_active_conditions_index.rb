class AddIsRetiredToRecordsActiveConditionsIndex < ActiveRecord::Migration[7.1]
  def up
    remove_index :records, name: "index_records_on_shop_and_active_conditions"
    add_index :records,
              %i[ramen_shop_id auto_retired is_retired is_test],
              name: "index_records_on_shop_and_active_conditions",
              where: "wait_time IS NOT NULL"
  end

  def down
    remove_index :records, name: "index_records_on_shop_and_active_conditions"
    add_index :records,
              %i[ramen_shop_id auto_retired is_test],
              name: "index_records_on_shop_and_active_conditions",
              where: "wait_time IS NOT NULL"
  end
end
