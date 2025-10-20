# frozen_string_literal: true

RSpec.configure do |config|
  # Include Devise test helpers for request specs
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Warden::Test::Helpers, type: :system
end
