# frozen_string_literal: true

require "capybara/rspec"

# Helper method for testing Phlex components
module PhlexComponentHelper
  def render_inline(component, &block)
    html = component.call(&block)
    @page = Capybara.string(html)
  end

  def page
    @page
  end
end

RSpec.configure do |config|
  config.include Capybara::RSpecMatchers, type: :component
  config.include PhlexComponentHelper, type: :component
end
