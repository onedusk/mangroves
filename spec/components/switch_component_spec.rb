# frozen_string_literal: true

require "rails_helper"

RSpec.describe SwitchComponent, type: :component do
  describe "#template" do
    it "renders a switch button" do
      component = described_class.new(name: "notifications")
      output = render(component)

      expect(output).to include('data-controller="switch"')
      expect(output).to include('role="switch"')
      expect(output).to include('name="notifications"')
      expect(output).to include('data-action="click->switch#toggle"')
    end

    context "when unchecked" do
      it "renders in unchecked state" do
        component = described_class.new(name: "setting", checked: false)
        output = render(component)

        expect(output).to include('aria-checked="false"')
        expect(output).to include('data-switch-checked-value="false"')
        expect(output).to include("bg-gray-200")
        expect(output).to include("translate-x-0")
      end
    end

    context "when checked" do
      it "renders in checked state" do
        component = described_class.new(name: "setting", checked: true)
        output = render(component)

        expect(output).to include('aria-checked="true"')
        expect(output).to include('data-switch-checked-value="true"')
        expect(output).to include("bg-blue-600")
        expect(output).to include("translate-x-5")
      end
    end

    context "with label" do
      it "renders label on the right by default" do
        component = described_class.new(
          name: "darkmode",
          label: "Dark Mode"
        )
        output = render(component)

        expect(output).to include("Dark Mode")
        # Label should appear after the switch in HTML
        expect(output.index("<button")).to be < output.index("Dark Mode")
      end

      it "renders label on the left when specified" do
        component = described_class.new(
          name: "feature",
          label: "Enable Feature",
          label_position: :left
        )
        output = render(component)

        expect(output).to include("Enable Feature")
        # Label should appear before the switch in HTML
        expect(output.index("Enable Feature")).to be < output.index("<button")
      end
    end

    context "when disabled" do
      it "disables the switch and shows disabled styling" do
        component = described_class.new(
          name: "readonly",
          disabled: true
        )
        output = render(component)

        expect(output).to include("disabled")
        expect(output).to include("opacity-50")
        expect(output).to include("cursor-not-allowed")
      end
    end

    it "includes hidden input for form submission" do
      component = described_class.new(name: "terms", checked: true)
      output = render(component)

      expect(output).to include('type="hidden"')
      expect(output).to include('name="terms"')
      expect(output).to include('value="true"')
      expect(output).to include('data-switch-target="input"')
    end
  end

  def render(component)
    html = render_inline(component)
    html.respond_to?(:native) ? html.native.to_html : html.to_s
  end
end
