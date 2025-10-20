# frozen_string_literal: true

require "rails_helper"

RSpec.describe ToggleComponent, type: :component do
  describe "#template" do
    it "renders a toggle with default settings" do
      component = described_class.new(name: "notifications")
      rendered = component.call

      expect(rendered).to include("data-controller=\"toggle\"")
      expect(rendered).to include("role=\"switch\"")
      expect(rendered).to include("aria-checked=\"false\"")
      expect(rendered).to include("name=\"notifications\"")
    end

    context "checked state" do
      it "renders as checked when checked is true" do
        component = described_class.new(name: "test", checked: true)
        rendered = component.call

        expect(rendered).to include("aria-checked=\"true\"")
        expect(rendered).to include("data-toggle-checked-value") # true values present
        expect(rendered).to include("bg-blue-600")
        expect(rendered).to include("value=\"1\"")
      end

      it "renders as unchecked when checked is false" do
        component = described_class.new(name: "test", checked: false)
        rendered = component.call

        expect(rendered).to include("aria-checked=\"false\"")
        expect(rendered).not_to include("data-toggle-checked-value") # false values omitted
        expect(rendered).to include("bg-gray-200")
        expect(rendered).to include("value=\"0\"")
      end
    end

    context "disabled state" do
      it "applies disabled styles and attribute" do
        component = described_class.new(name: "test", disabled: true)
        rendered = component.call

        expect(rendered).to include("disabled")
        expect(rendered).to include("opacity-50")
        expect(rendered).to include("cursor-not-allowed")
      end
    end

    context "with label" do
      it "renders the label" do
        component = described_class.new(name: "test", label: "Enable notifications")
        rendered = component.call

        expect(rendered).to include("Enable notifications")
      end
    end

    context "with icons" do
      it "includes icon elements when provided" do
        component = described_class.new(name: "test", icon_on: "✓", icon_off: "✗", checked: false)
        rendered = component.call

        expect(rendered).to include("data-toggle-target=\"icon\"")
        expect(rendered).to include("✗")
      end
    end

    context "sizes" do
      it "renders small size" do
        component = described_class.new(name: "test", size: :sm)
        rendered = component.call

        expect(rendered).to include("h-5 w-9")
        expect(rendered).to include("h-4 w-4")
      end

      it "renders medium size (default)" do
        component = described_class.new(name: "test", size: :md)
        rendered = component.call

        expect(rendered).to include("h-6 w-11")
        expect(rendered).to include("h-5 w-5")
      end

      it "renders large size" do
        component = described_class.new(name: "test", size: :lg)
        rendered = component.call

        expect(rendered).to include("h-8 w-14")
        expect(rendered).to include("h-7 w-7")
      end
    end

    it "includes Stimulus action" do
      component = described_class.new(name: "test")
      rendered = component.call

      expect(rendered).to include("click->toggle#toggle")
    end

    it "includes hidden input for form submission" do
      component = described_class.new(name: "test", checked: true)
      rendered = component.call

      expect(rendered).to include("type=\"hidden\"")
      expect(rendered).to include("data-toggle-target=\"input\"")
    end
  end
end
