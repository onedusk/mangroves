# frozen_string_literal: true

require "rails_helper"

RSpec.describe AspectRatioComponent, type: :component do
  describe "rendering" do
    it "renders with default 16:9 ratio" do
      component = described_class.new
      page = render_inline(component)

      container = page.find(".relative.w-full")
      expect(container["style"]).to include("padding-bottom: 56.25%")
    end

    it "renders content in absolute positioned div" do
      component = described_class.new
      page = render_inline(component)

      expect(page).to have_css(".absolute.inset-0")
    end
  end

  describe "ratio options" do
    it "supports 16:9 ratio" do
      component = described_class.new(ratio: "16:9")
      page = render_inline(component)

      container = page.find(".relative.w-full")
      expect(container["style"]).to include("padding-bottom: 56.25%")
    end

    it "supports 4:3 ratio" do
      component = described_class.new(ratio: "4:3")
      page = render_inline(component)

      container = page.find(".relative.w-full")
      expect(container["style"]).to include("padding-bottom: 75")
    end

    it "supports 1:1 ratio" do
      component = described_class.new(ratio: "1:1")
      page = render_inline(component)

      container = page.find(".relative.w-full")
      expect(container["style"]).to include("padding-bottom: 100")
    end

    it "supports 21:9 ratio" do
      component = described_class.new(ratio: "21:9")
      page = render_inline(component)

      container = page.find(".relative.w-full")
      expect(container["style"]).to include("padding-bottom: 42.86%")
    end

    it "supports 3:2 ratio" do
      component = described_class.new(ratio: "3:2")
      page = render_inline(component)

      container = page.find(".relative.w-full")
      expect(container["style"]).to include("padding-bottom: 66.67%")
    end

    it "supports 2:1 ratio" do
      component = described_class.new(ratio: "2:1")
      page = render_inline(component)

      container = page.find(".relative.w-full")
      expect(container["style"]).to include("padding-bottom: 50")
    end

    it "falls back to 16:9 for invalid ratio" do
      component = described_class.new(ratio: "invalid")
      page = render_inline(component)

      container = page.find(".relative.w-full")
      expect(container["style"]).to include("padding-bottom: 56.25%")
    end
  end

  describe "layout" do
    it "has relative positioning on container" do
      component = described_class.new
      page = render_inline(component)

      expect(page).to have_css(".relative.w-full")
    end

    it "has full width container" do
      component = described_class.new
      page = render_inline(component)

      container = page.find(".relative")
      expect(container[:class]).to include("w-full")
    end

    it "has absolute positioned inner div" do
      component = described_class.new
      page = render_inline(component)

      expect(page).to have_css(".absolute.inset-0")
    end
  end
end
