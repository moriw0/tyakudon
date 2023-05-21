class CreateLineStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :line_statuses do |t|
      t.references :record, null: false, foreign_key: true
      t.integer :line_number
      t.integer :line_type
      t.string :comment

      t.timestamps
    end
  end
end
