class LandingPageController < ApplicationController
  before_action :disable_connect_button
  layout 'lp'

  # rubocop:disable Metrics/AbcSize
  def index
    @today = Time.zone.today.strftime('%-m月%-d日')
    @users_count = User.all.count
    @records_count = Record.where(is_test: false).count
    @longest_record = Record.not_retired.with_associations.order_by_longest_wait.first
    @most_like_record = Record.not_retired.with_associations.order_by_most_likes.first
    @shortest_record = Record.not_retired.with_associations.order_by_shortest_wait.first
    @faqs = Faq.all.limit(5)
  end
  # rubocop:enable Metrics/AbcSize
end
