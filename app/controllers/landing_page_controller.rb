class LandingPageController < ApplicationController
  before_action :disable_connect_button
  layout 'lp'

  def index
    @faqs = Faq.all.limit(5)
  end
end
