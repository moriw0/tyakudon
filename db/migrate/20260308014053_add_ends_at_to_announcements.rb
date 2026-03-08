class AddEndsAtToAnnouncements < ActiveRecord::Migration[7.1]
  def change
    add_column :announcements, :ends_at, :datetime
    add_index  :announcements, :ends_at
  end
end
