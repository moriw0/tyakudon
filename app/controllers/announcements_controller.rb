class AnnouncementsController < ApplicationController
  def index
    @announcements = Announcement.published.recent
    # rubocop:disable Rails/SkipsModelValidations
    current_user.update_column(:last_read_announcement_at, Time.current) if logged_in?
    # rubocop:enable Rails/SkipsModelValidations
  end

  def show
    @announcement = Announcement.published.find(params[:id])
  end
end
