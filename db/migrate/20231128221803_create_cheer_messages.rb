class CreateCheerMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :cheer_messages do |t|
      t.references :record, null: false, foreign_key: true
      t.text :content
      t.integer :role

      t.timestamps
    end
  end
end
