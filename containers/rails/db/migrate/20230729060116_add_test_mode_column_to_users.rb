class AddTestModeColumnToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :is_test_mode, :boolean, default: false
  end
end
