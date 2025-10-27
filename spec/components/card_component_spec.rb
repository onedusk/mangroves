# frozen_string_literal: true

require "rails_helper"

RSpec.describe CardComponent, type: :component do
  describe "#template" do
    it "renders a card with title and content" do
      component = described_class.new(title: "Card Title") do |c|
        c.plain "Card content"
      end
      rendered = component.call

      expect(rendered).to include("Card Title")
      expect(rendered).to include("Card content")
    end

    it "includes proper structure classes" do
      component = described_class.new(title: "Test")
      rendered = component.call

      expect(rendered).to include("rounded-lg")
      expect(rendered).to include("shadow")
      expect(rendered).to include("bg-white")
    end

    it "supports custom padding" do
      component = described_class.new(title: "Test", padding: :none)
      rendered = component.call

      expect(rendered).not_to include("p-6")
    end

    it "renders footer when provided" do
      component = described_class.new(title: "Test", footer: "Footer text")
      rendered = component.call

      expect(rendered).to include("Footer text")
    end

    it "supports hover effect" do
      component = described_class.new(title: "Test", hoverable: true)
      rendered = component.call

      expect(rendered).to include("hover:shadow-lg").or include("transition")
    end
  end

  describe "XSS protection" do
    it "escapes HTML in title" do
      component = described_class.new(title: "<script>alert('XSS')</script>")
      rendered = component.call

      expect(rendered).not_to include("<script>")
      expect(rendered).to include("&lt;script&gt;")
    end

    it "escapes HTML in footer" do
      component = described_class.new(title: "Safe", footer: "<img src=x onerror=alert('XSS')>")
      rendered = component.call

      expect(rendered).not_to include("onerror=")
      expect(rendered).to include("&lt;img")
    end
  end
end
