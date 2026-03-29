class StaticsController < ApplicationController
  before_action :disable_connect_button
  before_action :use_v2_layout!, only: %i[terms privacy_policy]

  def terms
  end

  def privacy_policy
  end
end
