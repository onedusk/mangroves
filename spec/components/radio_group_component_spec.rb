# frozen_string_literal: true

require "rails_helper"

RSpec.describe RadioGroupComponent, type: :component do
  describe "#template" do
    context "with vertical layout" do
      it "renders radio buttons in vertical layout" do
        options = [["value1", "Label 1"], ["value2", "Label 2"]]
        component = described_class.new(name: "choice", options: options)
        output = render(component)

        expect(output).to include("flex flex-col gap-2")
        expect(output).to include('name="choice"')
        expect(output).to include('value="value1"')
        expect(output).to include('value="value2"')
        expect(output).to include("Label 1")
        expect(output).to include("Label 2")
      end
    end

    context "with horizontal layout" do
      it "renders radio buttons in horizontal layout" do
        options = ["Option A", "Option B"]
        component = described_class.new(
          name: "preference",
          options: options,
          layout: :horizontal
        )
        output = render(component)

        expect(output).to include("flex gap-4")
        expect(output).to include("Option A")
        expect(output).to include("Option B")
      end
    end

    context "with selected value" do
      it "marks the selected option as checked" do
        options = [["a", "A"], ["b", "B"], ["c", "C"]]
        component = described_class.new(
          name: "letter",
          options: options,
          selected: "b"
        )
        output = render(component)

        expect(output).to include('value="b" checked')
        expect(output).not_to include('value="a" checked')
        expect(output).not_to include('value="c" checked')
      end
    end

    context "with label" do
      it "renders group label" do
        component = described_class.new(
          name: "size",
          options: ["S", "M", "L"],
          label: "Select Size"
        )
        output = render(component)

        expect(output).to include("Select Size")
        expect(output).to include("text-sm font-medium text-gray-700")
      end
    end

    context "with simple string options" do
      it "uses strings as both value and label" do
        component = described_class.new(
          name: "color",
          options: ["Red", "Blue", "Green"]
        )
        output = render(component)

        expect(output).to include('value="Red"')
        expect(output).to include(">Red</span>")
        expect(output).to include('value="Blue"')
        expect(output).to include(">Blue</span>")
      end
    end
  end

  def render(component)
    html = render_inline(component)
    html.respond_to?(:native) ? html.native.to_html : html.to_s
  end
end
