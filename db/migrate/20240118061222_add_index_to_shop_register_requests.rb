class AddIndexToShopRegisterRequests < ActiveRecord::Migration[7.0]
  def change
    add_index :shop_register_requests, [:name, :address], unique: true
  end
end
