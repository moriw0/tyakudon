class AddLastReadAnnouncementAtToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :last_read_announcement_at, :datetime
  end
end
