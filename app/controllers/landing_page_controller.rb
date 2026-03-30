class LandingPageController < ApplicationController
  before_action :disable_connect_button
  before_action :use_v2_layout!, only: %i[index]
  layout :resolve_lp_layout

  def index
    @new_records = Record.new_records.limit(5)
    @faqs = Faq.order(created_at: :desc).limit(3)
  end

  private

  def resolve_lp_layout
    cookies[:v2_ui].present? ? 'v2' : 'lp'
  end
end
