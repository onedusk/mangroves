# frozen_string_literal: true

require "rails_helper"

RSpec.describe SeparatorComponent, type: :component do
  describe "#template" do
    context "with horizontal orientation" do
      it "renders a horizontal separator" do
        component = described_class.new(orientation: :horizontal)
        rendered = component.call

        expect(rendered).to include("h-px w-full")
        expect(rendered).to include("bg-gray-200")
        expect(rendered).to include("aria-orientation=\"horizontal\"")
      end
    end

    context "with vertical orientation" do
      it "renders a vertical separator" do
        component = described_class.new(orientation: :vertical)
        rendered = component.call

        expect(rendered).to include("w-px h-full")
        expect(rendered).to include("bg-gray-200")
        expect(rendered).to include("aria-orientation=\"vertical\"")
      end
    end

    context "with decorative role" do
      it "renders with role none" do
        component = described_class.new(decorative: true)
        rendered = component.call

        expect(rendered).to include("role=\"none\"")
      end
    end

    context "with non-decorative role" do
      it "renders with role separator" do
        component = described_class.new(decorative: false)
        rendered = component.call

        expect(rendered).to include("role=\"separator\"")
      end
    end

    context "with custom class" do
      it "includes the custom class" do
        component = described_class.new(class_name: "my-custom-class")
        rendered = component.call

        expect(rendered).to include("my-custom-class")
      end
    end
  end
end
