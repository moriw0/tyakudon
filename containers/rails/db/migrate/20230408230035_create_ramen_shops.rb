class CreateRamenShops < ActiveRecord::Migration[7.0]
  def change
    create_table :ramen_shops do |t|
      t.string :name
      t.string :address
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
