# frozen_string_literal: true

require "rails_helper"

RSpec.describe PopoverComponent, type: :component do
  describe "rendering" do
    it "renders with default options" do
      component = described_class.new(trigger_content: "Click me")
      page = render_inline(component)

      expect(page).to have_css("[data-controller='popover']")
      expect(page).to have_css("[data-popover-target='trigger']", text: "Click me")
      expect(page).to have_css("[data-popover-target='content']")
    end

    it "renders with custom align and side" do
      component = described_class.new(trigger_content: "Trigger", align: "start", side: "top")
      page = render_inline(component)

      expect(page).to have_css("[data-popover-align-value='start']")
      expect(page).to have_css("[data-popover-side-value='top']")
    end

    it "renders with custom offset" do
      component = described_class.new(trigger_content: "Trigger", offset: 16)
      page = render_inline(component)

      expect(page).to have_css("[data-popover-offset-value='16']")
    end

    it "has hidden content initially" do
      component = described_class.new(trigger_content: "Trigger")
      page = render_inline(component)

      expect(page).to have_css("[data-popover-target='content'].hidden")
    end

    it "has click handler on trigger" do
      component = described_class.new(trigger_content: "Trigger")
      page = render_inline(component)

      expect(page).to have_css("[data-action='click->popover#toggle']")
    end
  end

  describe "positioning" do
    it "sets z-index for proper layering" do
      component = described_class.new(trigger_content: "Trigger")
      page = render_inline(component)

      expect(page).to have_css("[data-popover-target='content'].z-50")
    end

    it "renders with shadow for depth" do
      component = described_class.new(trigger_content: "Trigger")
      page = render_inline(component)

      expect(page).to have_css("[data-popover-target='content'].shadow-lg")
    end

    it "renders with padding" do
      component = described_class.new(trigger_content: "Trigger")
      page = render_inline(component)

      expect(page).to have_css("[data-popover-target='content'].p-4")
    end
  end

  describe "accessibility" do
    it "has proper data attributes for controller connection" do
      component = described_class.new(trigger_content: "Trigger")
      page = render_inline(component)

      trigger = page.find("[data-popover-target='trigger']")
      expect(trigger).to be_present
    end
  end
end
