# frozen_string_literal: true

require "rails_helper"

RSpec.describe ButtonComponent, type: :component do
  describe "#template" do
    it "renders a button with text" do
      component = described_class.new("Click me")
      rendered = component.call

      expect(rendered).to include("Click me")
      expect(rendered).to include("button")
    end

    it "renders with default variant" do
      component = described_class.new("Button")
      rendered = component.call

      expect(rendered).to include("bg-gray-800")
      expect(rendered).to include("hover:bg-gray-900")
    end

    it "renders primary variant" do
      component = described_class.new("Primary", variant: :primary)
      rendered = component.call

      expect(rendered).to include("bg-blue-700")
      expect(rendered).to include("hover:bg-blue-800")
    end

    it "renders secondary variant" do
      component = described_class.new("Secondary", variant: :secondary)
      rendered = component.call

      expect(rendered).to include("bg-white")
      expect(rendered).to include("border-gray-200")
    end

    it "renders danger variant" do
      component = described_class.new("Delete", variant: :danger)
      rendered = component.call

      expect(rendered).to include("bg-red-700")
      expect(rendered).to include("hover:bg-red-800")
    end

    it "renders small size" do
      component = described_class.new("Small", size: :sm)
      rendered = component.call

      expect(rendered).to include("px-3 py-2")
      expect(rendered).to include("text-sm")
    end

    it "renders medium size by default" do
      component = described_class.new("Medium")
      rendered = component.call

      expect(rendered).to include("px-4 py-2.5")
    end

    it "renders large size" do
      component = described_class.new("Large", size: :lg)
      rendered = component.call

      expect(rendered).to include("px-5 py-3")
      expect(rendered).to include("text-base")
    end

    it "renders with submit type" do
      component = described_class.new("Submit", type: :submit)
      rendered = component.call

      expect(rendered).to include('type="submit"')
    end

    it "renders as disabled" do
      component = described_class.new("Disabled", disabled: true)
      rendered = component.call

      expect(rendered).to include("disabled")
    end

    it "includes focus ring for accessibility" do
      component = described_class.new("Accessible")
      rendered = component.call

      expect(rendered).to include("focus:outline-none")
      expect(rendered).to include("focus:ring-4")
    end
  end

  describe "XSS protection" do
    it "escapes HTML in button text" do
      component = described_class.new("<script>alert('XSS')</script>")
      rendered = component.call

      expect(rendered).not_to include("<script>")
      expect(rendered).to include("&lt;script&gt;")
    end

    it "handles special characters safely" do
      component = described_class.new("Button <>&\"")
      rendered = component.call

      expect(rendered).to include("&lt;")
      expect(rendered).to include("&gt;")
      expect(rendered).to include("&amp;")
    end
  end
end
