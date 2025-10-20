# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResizableComponent, type: :component do
  describe "#template" do
    context "with horizontal orientation" do
      it "renders a horizontal resizable container" do
        component = described_class.new(orientation: :horizontal, default_size: 50)
        rendered = component.call do |panel|
          case panel
          when :panel1
            "Panel 1 Content"
          when :panel2
            "Panel 2 Content"
          end
        end

        expect(rendered).to include("flex flex-row")
        expect(rendered).to include("cursor-col-resize")
        expect(rendered).to include("width: 50%")
        expect(rendered).to include("data-resizable-orientation-value=\"horizontal\"")
      end
    end

    context "with vertical orientation" do
      it "renders a vertical resizable container" do
        component = described_class.new(orientation: :vertical, default_size: 60)
        rendered = component.call do |panel|
          case panel
          when :panel1
            "Panel 1 Content"
          when :panel2
            "Panel 2 Content"
          end
        end

        expect(rendered).to include("flex flex-col")
        expect(rendered).to include("cursor-row-resize")
        expect(rendered).to include("height: 60%")
        expect(rendered).to include("data-resizable-orientation-value=\"vertical\"")
      end
    end

    context "with min and max size constraints" do
      it "sets the size constraints in data attributes" do
        component = described_class.new(min_size: 20, max_size: 80)
        rendered = component.call { "" }

        expect(rendered).to include("data-resizable-min-size-value=\"20\"")
        expect(rendered).to include("data-resizable-max-size-value=\"80\"")
      end
    end

    it "includes Stimulus controller" do
      component = described_class.new
      rendered = component.call { "" }

      expect(rendered).to include("data-controller=\"resizable\"")
    end

    it "includes drag handle" do
      component = described_class.new
      rendered = component.call { "" }

      expect(rendered).to include("data-resizable-target=\"handle\"")
      expect(rendered).to include("mousedown->resizable#startResize")
    end
  end
end
