# frozen_string_literal: true

require "rails_helper"

RSpec.describe SonnerComponent, type: :component do
  describe "#template" do
    it "renders a rich notification" do
      component = described_class.new(message: "Action completed")
      output = render(component)

      expect(output).to include("Action completed")
      expect(output).to include('data-controller="sonner"')
      expect(output).to include('role="alert"')
      expect(output).to include("sonner")
    end

    context "with different variants" do
      it "renders success variant" do
        component = described_class.new(
          message: "Success!",
          variant: :success
        )
        output = render(component)

        expect(output).to include("bg-green-50")
        expect(output).to include("text-green-800")
      end

      it "renders error variant" do
        component = described_class.new(
          message: "Failed",
          variant: :error
        )
        output = render(component)

        expect(output).to include("bg-red-50")
        expect(output).to include("text-red-800")
      end

      it "renders warning variant" do
        component = described_class.new(
          message: "Caution",
          variant: :warning
        )
        output = render(component)

        expect(output).to include("bg-yellow-50")
        expect(output).to include("text-yellow-800")
      end

      it "renders promise variant with spinner" do
        component = described_class.new(
          message: "Loading...",
          variant: :promise
        )
        output = render(component)

        expect(output).to include("bg-blue-50")
        expect(output).to include("animate-spin")
      end

      it "renders default variant" do
        component = described_class.new(message: "Info")
        output = render(component)

        expect(output).to include("bg-white")
        expect(output).to include("text-gray-800")
      end
    end

    context "with action button" do
      it "renders action link when provided" do
        component = described_class.new(
          message: "Update available",
          action_label: "Update Now",
          action_url: "/update"
        )
        output = render(component)

        expect(output).to include("Update Now")
        # SECURITY: safe_url() may percent-encode URLs
        expect(output).to match(/href="[^"]*update[^"]*"/)
        expect(output).to include("underline")
      end
    end

    context "with undo functionality" do
      it "renders undo button when callback provided" do
        component = described_class.new(
          message: "Item deleted",
          undo_callback: "undo" # SECURITY: Must use registered callback
        )
        output = render(component)

        expect(output).to include("Undo")
        expect(output).to include('data-action="sonner#undo"')
        # SECURITY: Removed undo_callback_value to prevent code injection
      end
    end

    context "with duration" do
      it "sets duration data value" do
        component = described_class.new(
          message: "Temporary",
          duration: 3000
        )
        output = render(component)

        expect(output).to include('data-sonner-duration-value="3000"')
      end

      it "renders progress bar when duration is set" do
        component = described_class.new(
          message: "With progress",
          duration: 5000
        )
        output = render(component)

        expect(output).to include("sonner-progress")
        expect(output).to include('data-sonner-target="progress"')
      end

      it "does not render progress bar when duration is 0" do
        component = described_class.new(
          message: "No auto-dismiss",
          duration: 0
        )
        output = render(component)

        expect(output).not_to include("sonner-progress")
      end
    end

    context "when dismissible" do
      it "renders dismiss button by default" do
        component = described_class.new(message: "Dismissible")
        output = render(component)

        expect(output).to include('data-action="sonner#dismiss"')
      end
    end

    context "when not dismissible" do
      it "does not render dismiss button" do
        component = described_class.new(
          message: "Not dismissible",
          dismissible: false
        )
        output = render(component)

        expect(output).not_to include('data-action="sonner#dismiss"')
      end
    end

    it "uses wider max width than toast" do
      component = described_class.new(message: "Rich notification")
      output = render(component)

      expect(output).to include("max-w-md")
    end
  end

  def render(component)
    html = render_inline(component)
    html.respond_to?(:native) ? html.native.to_html : html.to_s
  end
end
