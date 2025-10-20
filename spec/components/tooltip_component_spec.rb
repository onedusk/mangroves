# frozen_string_literal: true

require "rails_helper"

RSpec.describe TooltipComponent, type: :component do
  describe "rendering" do
    it "renders with text" do
      component = described_class.new(text: "Tooltip text")
      page = render_inline(component)

      expect(page).to have_css("[data-controller='tooltip']")
      expect(page).to have_css("[data-tooltip-target='content']", text: "Tooltip text")
    end

    it "renders with default position" do
      component = described_class.new(text: "Tooltip text")
      page = render_inline(component)

      expect(page).to have_css("[data-tooltip-position-value='top']")
    end

    it "renders with custom position" do
      component = described_class.new(text: "Tooltip", position: "bottom")
      page = render_inline(component)

      expect(page).to have_css("[data-tooltip-position-value='bottom']")
    end

    it "renders with custom delay" do
      component = described_class.new(text: "Tooltip", delay: 500)
      page = render_inline(component)

      expect(page).to have_css("[data-tooltip-delay-value='500']")
    end

    it "has hidden content initially" do
      component = described_class.new(text: "Tooltip text")
      page = render_inline(component)

      expect(page).to have_css("[data-tooltip-target='content'].hidden")
    end

    it "renders arrow element" do
      component = described_class.new(text: "Tooltip text")
      page = render_inline(component)

      expect(page).to have_css("[data-tooltip-target='arrow']")
    end
  end

  describe "interaction handlers" do
    it "has mouse handlers on trigger" do
      component = described_class.new(text: "Tooltip text")
      page = render_inline(component)

      trigger = page.find("[data-tooltip-target='trigger']")
      actions = trigger["data-action"]

      expect(actions).to include("mouseenter->tooltip#show")
      expect(actions).to include("mouseleave->tooltip#hide")
    end

    it "has focus handlers on trigger" do
      component = described_class.new(text: "Tooltip text")
      page = render_inline(component)

      trigger = page.find("[data-tooltip-target='trigger']")
      actions = trigger["data-action"]

      expect(actions).to include("focus->tooltip#show")
      expect(actions).to include("blur->tooltip#hide")
    end
  end

  describe "styling" do
    it "renders with dark background" do
      component = described_class.new(text: "Tooltip text")
      page = render_inline(component)

      expect(page).to have_css("[data-tooltip-target='content'].bg-gray-900")
    end

    it "renders with white text" do
      component = described_class.new(text: "Tooltip text")
      page = render_inline(component)

      expect(page).to have_css("[data-tooltip-target='content'].text-white")
    end

    it "renders with small text size" do
      component = described_class.new(text: "Tooltip text")
      page = render_inline(component)

      expect(page).to have_css("[data-tooltip-target='content'].text-xs")
    end

    it "renders with z-50 for proper layering" do
      component = described_class.new(text: "Tooltip text")
      page = render_inline(component)

      expect(page).to have_css("[data-tooltip-target='content'].z-50")
    end

    it "renders arrow with rotation" do
      component = described_class.new(text: "Tooltip text")
      page = render_inline(component)

      arrow = page.find("[data-tooltip-target='arrow']")
      expect(arrow[:class]).to include("rotate-45")
    end
  end

  describe "accessibility" do
    it "uses whitespace-nowrap for text wrapping" do
      component = described_class.new(text: "Tooltip text")
      page = render_inline(component)

      expect(page).to have_css("[data-tooltip-target='content'].whitespace-nowrap")
    end
  end
end
