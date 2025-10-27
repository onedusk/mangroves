# frozen_string_literal: true

require "capybara/rspec"

# Configure Capybara for component tests
Capybara.enable_aria_label = true

# Helper method for testing Phlex components
module PhlexComponentHelper
  # Wrapper class to provide both HTML string and Capybara node functionality
  class RenderedComponent
    attr_reader :html, :page

    def initialize(html)
      @html = html
      @page = Capybara.string(html)
    end

    def to_html
      @html
    end

    def to_s
      @html
    end

    # Delegate Capybara methods to the page node
    def method_missing(method, ...)
      if @page.respond_to?(method)
        @page.public_send(method, ...)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      @page.respond_to?(method, include_private) || super
    end
  end

  def render_inline(component, &)
    html = component.call(&)
    @rendered = RenderedComponent.new(html)
  end

  def page
    @rendered&.page
  end
end

RSpec.configure do |config|
  config.include Capybara::RSpecMatchers, type: :component
  config.include PhlexComponentHelper, type: :component

  # Stub ApplicationController.helpers for Phlex component tests
  config.before(:each, type: :component) do
    allow(ApplicationController).to receive(:helpers).and_return(
      Class.new do
        include Rails.application.routes.url_helpers
        include Devise::Controllers::Helpers

        def default_url_options
          {host: "example.com"}
        end
      end.new
    )
  end
end
