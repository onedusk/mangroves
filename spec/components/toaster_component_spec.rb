# frozen_string_literal: true

require "rails_helper"

RSpec.describe ToasterComponent, type: :component do
  describe "#template" do
    it "renders toaster container" do
      component = described_class.new
      output = render(component)

      expect(output).to include('id="toaster-container"')
      expect(output).to include('data-controller="toaster"')
      expect(output).to include('aria-live="polite"')
      expect(output).to include('aria-atomic="true"')
    end

    context "with different positions" do
      it "renders at top-right by default" do
        component = described_class.new
        output = render(component)

        expect(output).to include("top-4 right-4")
      end

      it "renders at top-left" do
        component = described_class.new(position: :top_left)
        output = render(component)

        expect(output).to include("top-4 left-4")
      end

      it "renders at top-center" do
        component = described_class.new(position: :top_center)
        output = render(component)

        expect(output).to include("top-4 left-1/2 -translate-x-1/2")
      end

      it "renders at bottom-left" do
        component = described_class.new(position: :bottom_left)
        output = render(component)

        expect(output).to include("bottom-4 left-4")
      end

      it "renders at bottom-center" do
        component = described_class.new(position: :bottom_center)
        output = render(component)

        expect(output).to include("bottom-4 left-1/2 -translate-x-1/2")
      end

      it "renders at bottom-right" do
        component = described_class.new(position: :bottom_right)
        output = render(component)

        expect(output).to include("bottom-4 right-4")
      end
    end

    it "has container target for toast messages" do
      component = described_class.new
      output = render(component)

      expect(output).to include('data-toaster-target="container"')
    end

    it "uses fixed positioning and high z-index" do
      component = described_class.new
      output = render(component)

      expect(output).to include("fixed z-50")
    end

    it "accepts block content" do
      component = described_class.new
      output = component.call do
        "<div>Toast 1</div><div>Toast 2</div>"
      end

      expect(output).to include("Toast 1")
      expect(output).to include("Toast 2")
    end
  end

  def render(component)
    html = render_inline(component)
    html.respond_to?(:native) ? html.native.to_html : html.to_s
  end
end
