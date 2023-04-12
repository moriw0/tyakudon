class CreateRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :records do |t|
      t.references :ramen_shop, null: false, foreign_key: true
      t.datetime :started_at
      t.datetime :ended_at
      t.datetime :elapsed_time

      t.timestamps
    end
  end
end
