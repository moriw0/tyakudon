class AddAutoRetiredToRecords < ActiveRecord::Migration[7.0]
  def change
    add_column :records, :auto_retired, :boolean, default: false
  end
end
