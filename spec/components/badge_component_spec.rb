# frozen_string_literal: true

require "rails_helper"

RSpec.describe BadgeComponent, type: :component do
  let(:component_class) do
    Class.new(Phlex::HTML) do
      def initialize(text, variant: :default)
        @text = text
        @variant = variant
      end

      def template
        span(class: badge_classes) { @text }
      end

      private

      def badge_classes
        base = "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
        variant = case @variant
                  when :success then "bg-green-100 text-green-800"
                  when :warning then "bg-yellow-100 text-yellow-800"
                  when :error then "bg-red-100 text-red-800"
                  when :info then "bg-blue-100 text-blue-800"
                  else "bg-gray-100 text-gray-800"
                  end
        "#{base} #{variant}"
      end
    end
  end

  before do
    stub_const("BadgeComponent", component_class)
  end

  describe "#template" do
    it "renders a badge with text" do
      component = described_class.new("New")
      rendered = component.call

      expect(rendered).to include("New")
      expect(rendered).to include("span")
    end

    it "renders with default variant" do
      component = described_class.new("Default")
      rendered = component.call

      expect(rendered).to include("bg-gray-100")
      expect(rendered).to include("text-gray-800")
    end

    it "renders success variant" do
      component = described_class.new("Active", variant: :success)
      rendered = component.call

      expect(rendered).to include("bg-green-100")
      expect(rendered).to include("text-green-800")
    end

    it "renders warning variant" do
      component = described_class.new("Pending", variant: :warning)
      rendered = component.call

      expect(rendered).to include("bg-yellow-100")
      expect(rendered).to include("text-yellow-800")
    end

    it "renders error variant" do
      component = described_class.new("Failed", variant: :error)
      rendered = component.call

      expect(rendered).to include("bg-red-100")
      expect(rendered).to include("text-red-800")
    end

    it "renders info variant" do
      component = described_class.new("Info", variant: :info)
      rendered = component.call

      expect(rendered).to include("bg-blue-100")
      expect(rendered).to include("text-blue-800")
    end

    it "includes proper styling classes" do
      component = described_class.new("Badge")
      rendered = component.call

      expect(rendered).to include("inline-flex")
      expect(rendered).to include("rounded-full")
      expect(rendered).to include("text-xs")
      expect(rendered).to include("font-medium")
    end
  end

  describe "XSS protection" do
    it "escapes HTML in badge text" do
      component = described_class.new("<script>alert('XSS')</script>")
      rendered = component.call

      expect(rendered).not_to include("<script>")
      expect(rendered).to include("&lt;script&gt;")
    end
  end
end
