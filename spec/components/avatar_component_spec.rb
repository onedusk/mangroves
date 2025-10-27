# frozen_string_literal: true

require "rails_helper"

RSpec.describe AvatarComponent, type: :component do
  describe "#template" do
    it "renders image avatar" do
      component = described_class.new(src: "https://example.com/avatar.jpg", alt: "User")
      rendered = component.call

      expect(rendered).to include("https://example.com/avatar.jpg")
      expect(rendered).to include("alt=\"User\"")
    end

    it "renders initials when no src provided" do
      component = described_class.new(initials: "JD")
      rendered = component.call

      expect(rendered).to include("JD")
    end

    it "supports different sizes" do
      component = described_class.new(initials: "AB", size: :lg)
      rendered = component.call

      expect(rendered).to include("h-12 w-12").or include("h-16 w-16")
    end

    it "renders with rounded corners" do
      component = described_class.new(initials: "CD")
      rendered = component.call

      expect(rendered).to include("rounded-full")
    end

    it "includes proper accessibility attributes" do
      component = described_class.new(src: "avatar.jpg", alt: "John Doe")
      rendered = component.call

      expect(rendered).to include('alt="John Doe"')
    end
  end

  describe "XSS protection" do
    it "escapes alt text" do
      component = described_class.new(src: "avatar.jpg", alt: "<script>alert('XSS')</script>")
      rendered = component.call

      expect(rendered).not_to include("<script>")
      expect(rendered).to include("&lt;script&gt;")
    end

    it "sanitizes src attribute" do
      component = described_class.new(src: "javascript:alert('XSS')", alt: "Test")
      rendered = component.call

      expect(rendered).not_to include("javascript:")
    end

    it "escapes initials" do
      component = described_class.new(initials: "<>&\"")
      rendered = component.call

      expect(rendered).to include("&lt;")
      expect(rendered).to include("&gt;")
    end
  end
end
