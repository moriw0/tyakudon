class AddIsTestToRecords < ActiveRecord::Migration[7.0]
  def change
    add_column :records, :is_test, :boolean, default: false
  end
end
