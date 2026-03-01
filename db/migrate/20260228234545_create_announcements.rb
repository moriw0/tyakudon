class CreateAnnouncements < ActiveRecord::Migration[7.1]
  def change
    create_table :announcements do |t|
      t.string   :title,        null: false
      t.datetime :published_at, null: false

      t.timestamps
    end

    add_index :announcements, :published_at
  end
end
