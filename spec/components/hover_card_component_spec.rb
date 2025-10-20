# frozen_string_literal: true

require "rails_helper"

RSpec.describe HoverCardComponent, type: :component do
  describe "rendering" do
    it "renders with default options" do
      component = described_class.new(trigger_content: "Hover me")
      page = render_inline(component)

      expect(page).to have_css("[data-controller='hover-card']")
      expect(page).to have_css("[data-hover-card-target='trigger']", text: "Hover me")
      expect(page).to have_css("[data-hover-card-target='content']")
    end

    it "renders with custom delays" do
      component = described_class.new(trigger_content: "Hover me", open_delay: 500, close_delay: 200)
      page = render_inline(component)

      expect(page).to have_css("[data-hover-card-open-delay-value='500']")
      expect(page).to have_css("[data-hover-card-close-delay-value='200']")
    end

    it "renders with custom positioning" do
      component = described_class.new(trigger_content: "Hover me", align: "end", side: "bottom", offset: 12)
      page = render_inline(component)

      expect(page).to have_css("[data-hover-card-align-value='end']")
      expect(page).to have_css("[data-hover-card-side-value='bottom']")
      expect(page).to have_css("[data-hover-card-offset-value='12']")
    end

    it "has hidden content initially" do
      component = described_class.new(trigger_content: "Hover me")
      page = render_inline(component)

      expect(page).to have_css("[data-hover-card-target='content'].hidden")
    end

    it "has hover handlers on trigger" do
      component = described_class.new(trigger_content: "Hover me")
      page = render_inline(component)

      expect(page).to have_css("[data-action*='mouseenter->hover-card#scheduleOpen']")
      expect(page).to have_css("[data-action*='mouseleave->hover-card#scheduleClose']")
    end

    it "has hover handlers on content to prevent premature closing" do
      component = described_class.new(trigger_content: "Hover me")
      page = render_inline(component)

      content = page.find("[data-hover-card-target='content']")
      expect(content["data-action"]).to include("mouseenter->hover-card#cancelClose")
      expect(content["data-action"]).to include("mouseleave->hover-card#scheduleClose")
    end
  end

  describe "styling" do
    it "renders with fixed width for rich content" do
      component = described_class.new(trigger_content: "Hover me")
      page = render_inline(component)

      expect(page).to have_css("[data-hover-card-target='content'].w-64")
    end

    it "renders with padding for content" do
      component = described_class.new(trigger_content: "Hover me")
      page = render_inline(component)

      expect(page).to have_css("[data-hover-card-target='content'].p-4")
    end
  end
end
