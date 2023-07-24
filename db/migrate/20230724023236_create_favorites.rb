class CreateFavorites < ActiveRecord::Migration[7.0]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :ramen_shop, null: false, foreign_key: true

      t.timestamps
    end
    add_index :favorites, [:user_id, :ramen_shop_id], unique: true
  end
end
