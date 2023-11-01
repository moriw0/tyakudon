class ChangeColumnNullAndAddIndexToRamenShops < ActiveRecord::Migration[7.0]
  def change
    change_column_null :ramen_shops, :name, false
    change_column_null :ramen_shops, :address, false
    change_column_null :ramen_shops, :latitude, false
    change_column_null :ramen_shops, :longitude, false

    add_index :ramen_shops, [:name, :address], unique: true
  end
end
