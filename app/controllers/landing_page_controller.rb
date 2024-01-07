class LandingPageController < ApplicationController
  before_action :disable_connect_button
  layout 'lp'

  def index
    @longest_record = Record.not_retired.with_associations.order_by_longest_wait.first
    @most_like_record = Record.not_retired.with_associations.order_by_most_likes.first
    @shortest_record = Record.not_retired.with_associations.order_by_shortest_wait.first
  end
end
