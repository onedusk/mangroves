# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProgressComponent, type: :component do
  describe "#template" do
    it "renders a progress bar" do
      component = described_class.new(value: 50)
      output = render(component)

      expect(output).to include('role="progressbar"')
      expect(output).to include('aria-valuenow="50"')
      expect(output).to include('aria-valuemin="0"')
      expect(output).to include('aria-valuemax="100"')
    end

    context "with different values" do
      it "calculates correct percentage" do
        component = described_class.new(value: 25, max: 100)
        output = render(component)

        expect(output).to include("width: 25%")
      end

      it "calculates percentage for custom max" do
        component = described_class.new(value: 3, max: 10)
        output = render(component)

        expect(output).to include("width: 30%")
      end

      it "caps percentage at 100%" do
        component = described_class.new(value: 150, max: 100)
        output = render(component)

        expect(output).to include("width: 100%")
      end

      it "handles zero max value" do
        component = described_class.new(value: 10, max: 0)
        output = render(component)

        expect(output).to include("width: 0%")
      end
    end

    context "with different variants" do
      it "renders default blue variant" do
        component = described_class.new(value: 50)
        output = render(component)

        expect(output).to include("bg-blue-600")
      end

      it "renders success variant" do
        component = described_class.new(value: 100, variant: :success)
        output = render(component)

        expect(output).to include("bg-green-600")
      end

      it "renders warning variant" do
        component = described_class.new(value: 75, variant: :warning)
        output = render(component)

        expect(output).to include("bg-yellow-600")
      end

      it "renders error variant" do
        component = described_class.new(value: 10, variant: :error)
        output = render(component)

        expect(output).to include("bg-red-600")
      end
    end

    context "with different sizes" do
      it "renders medium size by default" do
        component = described_class.new(value: 50)
        output = render(component)

        expect(output).to include("h-2")
      end

      it "renders small size" do
        component = described_class.new(value: 50, size: :sm)
        output = render(component)

        expect(output).to include("h-1")
      end

      it "renders large size" do
        component = described_class.new(value: 50, size: :lg)
        output = render(component)

        expect(output).to include("h-4")
      end
    end

    context "when indeterminate" do
      it "renders indeterminate progress bar" do
        component = described_class.new(indeterminate: true)
        output = render(component)

        expect(output).to include("animate-progress-indeterminate")
        expect(output).not_to include("aria-valuenow")
        expect(output).not_to include("width:")
      end
    end

    context "with label" do
      it "renders label and percentage" do
        component = described_class.new(
          value: 60,
          label: "Uploading..."
        )
        output = render(component)

        expect(output).to include("Uploading...")
        expect(output).to include("60%")
      end

      it "does not show percentage for indeterminate" do
        component = described_class.new(
          indeterminate: true,
          label: "Processing..."
        )
        output = render(component)

        expect(output).to include("Processing...")
        expect(output).not_to include("%")
      end
    end

    it "includes transition classes for smooth animation" do
      component = described_class.new(value: 50)
      output = render(component)

      expect(output).to include("transition-all")
      expect(output).to include("duration-300")
      expect(output).to include("ease-in-out")
    end
  end

  def render(component)
    component.call
  end
end
