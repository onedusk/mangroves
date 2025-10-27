# frozen_string_literal: true

require "rails_helper"

RSpec.describe ToastComponent, type: :component do
  describe "#template" do
    it "renders a toast notification" do
      component = described_class.new(message: "Operation successful")
      output = render(component)

      expect(output).to include("Operation successful")
      expect(output).to include('data-controller="toast"')
      expect(output).to include('role="alert"')
      expect(output).to include("toast")
    end

    context "with different variants" do
      it "renders success variant" do
        component = described_class.new(
          message: "Saved!",
          variant: :success
        )
        output = render(component)

        expect(output).to include("bg-green-50")
        expect(output).to include("text-green-800")
        expect(output).to include("text-green-400")
      end

      it "renders error variant" do
        component = described_class.new(
          message: "Error occurred",
          variant: :error
        )
        output = render(component)

        expect(output).to include("bg-red-50")
        expect(output).to include("text-red-800")
        expect(output).to include("text-red-400")
      end

      it "renders warning variant" do
        component = described_class.new(
          message: "Warning",
          variant: :warning
        )
        output = render(component)

        expect(output).to include("bg-yellow-50")
        expect(output).to include("text-yellow-800")
        expect(output).to include("text-yellow-400")
      end

      it "renders info variant by default" do
        component = described_class.new(message: "Info")
        output = render(component)

        expect(output).to include("bg-blue-50")
        expect(output).to include("text-blue-800")
        expect(output).to include("text-blue-400")
      end
    end

    context "with custom duration" do
      it "sets the duration data value" do
        component = described_class.new(
          message: "Quick message",
          duration: 3000
        )
        output = render(component)

        expect(output).to include('data-toast-duration-value="3000"')
      end
    end

    context "when dismissible" do
      it "renders dismiss button by default" do
        component = described_class.new(message: "Can dismiss")
        output = render(component)

        expect(output).to include('data-action="toast#dismiss"')
        expect(output).to include("Dismiss")
      end
    end

    context "when not dismissible" do
      it "does not render dismiss button" do
        component = described_class.new(
          message: "Cannot dismiss",
          dismissible: false
        )
        output = render(component)

        expect(output).not_to include('data-action="toast#dismiss"')
      end
    end

    it "includes appropriate icon for variant" do
      component = described_class.new(
        message: "Test",
        variant: :success
      )
      output = render(component)

      expect(output).to include("<svg")
      expect(output).to include("viewbox=\"0 0 20 20\"")
      expect(output).to include("fill=\"currentColor\"")
    end
  end

  def render(component)
    html = render_inline(component)
    html.respond_to?(:native) ? html.native.to_html : html.to_s
  end
end
