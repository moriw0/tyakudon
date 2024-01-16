class CreateShopRegisterRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :shop_register_requests do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.text :remarks

      t.timestamps
    end
  end
end
