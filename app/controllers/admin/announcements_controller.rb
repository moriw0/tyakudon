module Admin
  class AnnouncementsController < Admin::BaseController
    before_action :set_announcement, only: %i[show edit update destroy]

    def index
      @announcements = Announcement.recent
    end

    def show
    end

    def new
      @announcement = Announcement.new
    end

    def edit
    end

    def create
      @announcement = Announcement.new(announcement_params)

      if @announcement.save
        redirect_to admin_announcement_url(@announcement), notice: 'お知らせを作成しました。'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @announcement.update(announcement_params)
        redirect_to admin_announcement_url(@announcement), notice: 'お知らせを更新しました。'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @announcement.destroy
      redirect_to admin_announcements_url, notice: 'お知らせを削除しました。'
    end

    private

    def set_announcement
      @announcement = Announcement.find(params[:id])
    end

    def announcement_params
      params.require(:announcement).permit(:title, :published_at, :body)
    end
  end
end
