module V2UiHelper
  module System
    def enable_v2_ui
      visit root_path(v2: 1) # rubocop:disable Naming/VariableNumber
    end
  end
end

RSpec.configure do |config|
  config.include V2UiHelper::System, type: :system
end
