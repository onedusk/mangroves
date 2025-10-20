# frozen_string_literal: true

require "rails_helper"

RSpec.describe SheetComponent, type: :component do
  describe "rendering" do
    it "renders with title" do
      component = described_class.new(title: "Test Sheet")
      page = render_inline(component)

      expect(page).to have_css("h2", text: "Test Sheet")
    end

    it "renders with controller" do
      component = described_class.new(title: "Test Sheet")
      page = render_inline(component)

      expect(page).to have_css("[data-controller='sheet']")
    end

    it "renders close button" do
      component = described_class.new(title: "Test Sheet")
      page = render_inline(component)

      expect(page).to have_css("[data-action='sheet#close']")
    end

    it "renders backdrop with close action" do
      component = described_class.new(title: "Test Sheet")
      page = render_inline(component)

      backdrop = page.find(".bg-gray-900.bg-opacity-50")
      expect(backdrop["data-action"]).to eq("click->sheet#close")
    end
  end

  describe "side positioning" do
    it "defaults to right side" do
      component = described_class.new(title: "Test Sheet")
      page = render_inline(component)

      expect(page).to have_css("[data-sheet-side-value='right']")
      expect(page).to have_css(".inset-y-0.right-0")
    end

    it "supports left side" do
      component = described_class.new(title: "Test", side: "left")
      page = render_inline(component)

      expect(page).to have_css("[data-sheet-side-value='left']")
      expect(page).to have_css(".inset-y-0.left-0")
    end

    it "supports top side" do
      component = described_class.new(title: "Test", side: "top")
      page = render_inline(component)

      expect(page).to have_css("[data-sheet-side-value='top']")
      expect(page).to have_css(".inset-x-0.top-0")
    end

    it "supports bottom side" do
      component = described_class.new(title: "Test", side: "bottom")
      page = render_inline(component)

      expect(page).to have_css("[data-sheet-side-value='bottom']")
      expect(page).to have_css(".inset-x-0.bottom-0")
    end
  end

  describe "layout" do
    it "has header section" do
      component = described_class.new(title: "Test Sheet")
      page = render_inline(component)

      expect(page).to have_css(".border-b.border-gray-200")
    end

    it "has scrollable content area" do
      component = described_class.new(title: "Test Sheet")
      page = render_inline(component)

      expect(page).to have_css(".overflow-y-auto")
    end

    it "has proper z-index" do
      component = described_class.new(title: "Test Sheet")
      page = render_inline(component)

      expect(page).to have_css(".z-50")
    end
  end

  describe "accessibility" do
    it "has sr-only text for close button" do
      component = described_class.new(title: "Test Sheet")
      page = render_inline(component)

      expect(page).to have_css(".sr-only", text: "Close panel")
    end

    it "has proper ARIA attributes on SVG" do
      component = described_class.new(title: "Test Sheet")
      page = render_inline(component)

      svg = page.find("svg")
      expect(svg["aria-hidden"]).to eq("true")
    end
  end
end
