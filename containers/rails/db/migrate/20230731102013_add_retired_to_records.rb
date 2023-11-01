class AddRetiredToRecords < ActiveRecord::Migration[7.0]
  def change
    add_column :records, :is_retired, :boolean, default: false
  end
end
