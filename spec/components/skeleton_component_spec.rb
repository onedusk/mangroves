# frozen_string_literal: true

require "rails_helper"

RSpec.describe SkeletonComponent, type: :component do
  describe "#template" do
    it "renders a skeleton loader" do
      component = described_class.new
      output = render(component)

      expect(output).to include("animate-pulse")
      expect(output).to include("bg-gray-200")
      expect(output).to include('aria-hidden="true"')
    end

    context "with different variants" do
      it "renders text variant by default" do
        component = described_class.new
        output = render(component)

        expect(output).to include("rounded h-4")
      end

      it "renders heading variant" do
        component = described_class.new(variant: :heading)
        output = render(component)

        expect(output).to include("rounded h-8")
      end

      it "renders circle variant" do
        component = described_class.new(variant: :circle)
        output = render(component)

        expect(output).to include("rounded-full")
      end

      it "renders rectangle variant" do
        component = described_class.new(variant: :rectangle)
        output = render(component)

        expect(output).to include("rounded-none")
      end

      it "renders avatar variant" do
        component = described_class.new(variant: :avatar)
        output = render(component)

        expect(output).to include("rounded-full h-10 w-10")
      end

      it "renders button variant" do
        component = described_class.new(variant: :button)
        output = render(component)

        expect(output).to include("rounded-md h-10")
      end

      it "renders card variant" do
        component = described_class.new(variant: :card)
        output = render(component)

        expect(output).to include("rounded-lg h-48")
      end
    end

    context "with custom dimensions" do
      it "applies custom width" do
        component = described_class.new(width: "200px")
        output = render(component)

        expect(output).to include("width: 200px")
      end

      it "applies custom height" do
        component = described_class.new(height: "50px")
        output = render(component)

        expect(output).to include("height: 50px")
      end

      it "applies both width and height" do
        component = described_class.new(width: "100%", height: "80px")
        output = render(component)

        expect(output).to include("width: 100%")
        expect(output).to include("height: 80px")
      end
    end

    context "with multiple skeletons" do
      it "renders single skeleton by default" do
        component = described_class.new
        output = render(component)

        expect(output.scan(/animate-pulse/).count).to eq(1)
      end

      it "renders multiple skeletons with spacing" do
        component = described_class.new(count: 3)
        output = render(component)

        expect(output).to include("space-y-2")
        expect(output.scan(/animate-pulse/).count).to eq(3)
      end

      it "allows custom spacing" do
        component = described_class.new(count: 4, space_y: 4)
        output = render(component)

        expect(output).to include("space-y-4")
        expect(output.scan(/animate-pulse/).count).to eq(4)
      end
    end

    it "has accessible markup" do
      component = described_class.new
      output = render(component)

      expect(output).to include('aria-hidden="true"')
    end
  end

  def render(component)
    html = render_inline(component)
    html.respond_to?(:native) ? html.native.to_html : html.to_s
  end
end
