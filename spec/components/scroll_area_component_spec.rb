# frozen_string_literal: true

require "rails_helper"

RSpec.describe ScrollAreaComponent, type: :component do
  describe "#template" do
    it "renders scroll area with default dimensions" do
      component = described_class.new
      rendered = component.call { "Content" }

      expect(rendered).to include("height: 400px")
      expect(rendered).to include("width: 100%")
      expect(rendered).to include("Content")
    end

    it "renders scroll area with custom dimensions" do
      component = described_class.new(height: "600px", width: "80%")
      rendered = component.call { "Content" }

      expect(rendered).to include("height: 600px")
      expect(rendered).to include("width: 80%")
    end

    it "includes Stimulus controller" do
      component = described_class.new
      rendered = component.call { "" }

      expect(rendered).to include("data-controller=\"scroll-area\"")
    end

    it "includes viewport target" do
      component = described_class.new
      rendered = component.call { "" }

      expect(rendered).to include("data-scroll-area-target=\"viewport\"")
    end

    it "includes scrollbar styling" do
      component = described_class.new
      rendered = component.call { "" }

      expect(rendered).to include("overflow-auto")
      expect(rendered).to include("scrollbar-custom")
    end

    it "includes custom class when provided" do
      component = described_class.new(class_name: "custom-scroll")
      rendered = component.call { "" }

      expect(rendered).to include("custom-scroll")
    end

    it "renders content inside scroll area" do
      component = described_class.new
      rendered = component.call do
        "Scrollable content goes here"
      end

      expect(rendered).to include("Scrollable content goes here")
      expect(rendered).to include("scroll-area-content")
    end
  end
end
