class CreateCheerMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :cheer_messages do |t|
      t.text :content
      t.references :record, null: false, foreign_key: true

      t.timestamps
    end
  end
end
