class AddColmunToRecord < ActiveRecord::Migration[7.0]
  def change
    add_column :records, :queue_number, :integer
    add_column :records, :wait_time, :float
    add_column :records, :status, :string
  end
end
