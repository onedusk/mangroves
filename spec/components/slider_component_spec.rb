# frozen_string_literal: true

require "rails_helper"

RSpec.describe SliderComponent, type: :component do
  describe "#template" do
    context "single value slider" do
      it "renders a single value slider with default settings" do
        component = described_class.new(name: "volume")
        rendered = component.call

        expect(rendered).to include("data-controller=\"slider\"")
        expect(rendered).to include("data-slider-min-value=\"0\"")
        expect(rendered).to include("data-slider-max-value=\"100\"")
        expect(rendered).not_to include("data-slider-range-value") # false values are omitted in Phlex
        expect(rendered).to include("name=\"volume\"")
      end

      it "renders with custom min, max, and value" do
        component = described_class.new(name: "brightness", min: 10, max: 200, value: 75)
        rendered = component.call

        expect(rendered).to include("data-slider-min-value=\"10\"")
        expect(rendered).to include("data-slider-max-value=\"200\"")
        expect(rendered).to include("value=\"75\"")
      end

      it "includes a single thumb" do
        component = described_class.new(name: "test")
        rendered = component.call

        expect(rendered).to include("data-slider-target=\"thumb\"")
        expect(rendered).to include("mousedown->slider#startDrag")
      end

      it "shows value label when enabled" do
        component = described_class.new(name: "test", value: 50, show_value: true)
        rendered = component.call

        expect(rendered).to include("data-slider-target=\"valueLabel\"")
        expect(rendered).to include("50")
      end
    end

    context "range slider" do
      it "renders a range slider" do
        component = described_class.new(name: "price", range: true, range_values: [20, 80])
        rendered = component.call

        expect(rendered).to include("data-slider-range-value") # true values are present
        expect(rendered).to include("data-slider-target=\"thumbMin\"")
        expect(rendered).to include("data-slider-target=\"thumbMax\"")
      end

      it "includes two hidden inputs for range values" do
        component = described_class.new(name: "price", range: true, range_values: [20, 80])
        rendered = component.call

        expect(rendered).to include("name=\"price[min]\"")
        expect(rendered).to include("name=\"price[max]\"")
        expect(rendered).to include("value=\"20\"")
        expect(rendered).to include("value=\"80\"")
      end

      it "shows range values in label" do
        component = described_class.new(name: "test", range: true, range_values: [25, 75], show_value: true)
        rendered = component.call

        expect(rendered).to include("25 - 75")
      end
    end

    context "disabled state" do
      it "applies disabled styles when disabled" do
        component = described_class.new(name: "test", disabled: true)
        rendered = component.call

        expect(rendered).to include("data-slider-disabled-value") # true values are present
        expect(rendered).to include("opacity-50")
        expect(rendered).to include("cursor-not-allowed")
      end
    end

    context "with custom step" do
      it "sets the step value" do
        component = described_class.new(name: "test", step: 5)
        rendered = component.call

        expect(rendered).to include("data-slider-step-value=\"5\"")
      end
    end
  end
end
