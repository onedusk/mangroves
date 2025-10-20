# frozen_string_literal: true

require "rails_helper"

RSpec.describe ToggleGroupComponent, type: :component do
  describe "#template" do
    let(:items) { ["Left", "Center", "Right"] }

    it "renders a toggle group with default settings" do
      component = described_class.new(name: "alignment", items: items)
      rendered = component.call

      expect(rendered).to include("data-controller=\"toggle-group\"")
      expect(rendered).to include("role=\"group\"")
      expect(rendered).not_to include("data-toggle-group-multiple-value") # false values omitted
    end

    it "renders all items" do
      component = described_class.new(name: "test", items: items)
      rendered = component.call

      expect(rendered).to include("Left")
      expect(rendered).to include("Center")
      expect(rendered).to include("Right")
    end

    context "single selection mode" do
      it "allows only one selection" do
        component = described_class.new(name: "test", items: items, selected: "Center", multiple: false)
        rendered = component.call

        expect(rendered).not_to include("data-toggle-group-multiple-value") # false values omitted
        expect(rendered).to include("data-toggle-group-selected-value=\"[&quot;Center&quot;]\"")
      end
    end

    context "multiple selection mode" do
      it "allows multiple selections" do
        component = described_class.new(
          name: "test",
          items: items,
          selected: ["Left", "Right"],
          multiple: true
        )
        rendered = component.call

        expect(rendered).to include("data-toggle-group-multiple-value") # true values present
        expect(rendered).to include("data-toggle-group-selected-value=\"[&quot;Left&quot;,&quot;Right&quot;]\"")
      end
    end

    context "with hash items including icons" do
      let(:hash_items) do
        [
          {value: "bold", label: "Bold", icon: "B"},
          {value: "italic", label: "Italic", icon: "I"}
        ]
      end

      it "renders items with icons" do
        component = described_class.new(name: "format", items: hash_items)
        rendered = component.call

        expect(rendered).to include("Bold")
        expect(rendered).to include("Italic")
        expect(rendered).to include("data-value=\"bold\"")
        expect(rendered).to include("data-value=\"italic\"")
      end
    end

    context "disabled items" do
      let(:items_with_disabled) do
        [
          {value: "one", label: "One"},
          {value: "two", label: "Two", disabled: true},
          {value: "three", label: "Three"}
        ]
      end

      it "renders disabled state for specific items" do
        component = described_class.new(name: "test", items: items_with_disabled)
        rendered = component.call

        expect(rendered).to include("opacity-50")
        expect(rendered).to include("cursor-not-allowed")
      end
    end

    context "disabled group" do
      it "disables all items when group is disabled" do
        component = described_class.new(name: "test", items: items, disabled: true)
        rendered = component.call

        # All items should have disabled styling
        disabled_count = rendered.scan(/opacity-50/).length
        expect(disabled_count).to eq(items.length)
      end
    end

    context "variants" do
      it "renders default variant" do
        component = described_class.new(name: "test", items: items, variant: :default)
        rendered = component.call

        expect(rendered).to include("bg-gray-100")
      end

      it "renders outline variant" do
        component = described_class.new(name: "test", items: items, variant: :outline)
        rendered = component.call

        expect(rendered).to include("border border-gray-300")
      end
    end

    context "sizes" do
      it "renders small size" do
        component = described_class.new(name: "test", items: items, size: :sm)
        rendered = component.call

        expect(rendered).to include("px-3 py-1.5 text-xs")
      end

      it "renders medium size (default)" do
        component = described_class.new(name: "test", items: items, size: :md)
        rendered = component.call

        expect(rendered).to include("px-4 py-2 text-sm")
      end

      it "renders large size" do
        component = described_class.new(name: "test", items: items, size: :lg)
        rendered = component.call

        expect(rendered).to include("px-6 py-3 text-base")
      end
    end

    it "includes Stimulus actions" do
      component = described_class.new(name: "test", items: items)
      rendered = component.call

      expect(rendered).to include("click->toggle-group#toggle")
    end

    it "applies rounded corners to edge items" do
      component = described_class.new(name: "test", items: items)
      rendered = component.call

      expect(rendered).to include("rounded-l-lg")
      expect(rendered).to include("rounded-r-lg")
    end
  end
end
