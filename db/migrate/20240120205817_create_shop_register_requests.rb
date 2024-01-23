class CreateShopRegisterRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :shop_register_requests do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.text :remarks
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false

      t.timestamps
    end

    add_index :shop_register_requests, [:address, :name], unique: true
  end
end
