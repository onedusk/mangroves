# frozen_string_literal: true

require "rails_helper"

RSpec.describe AccordionComponent, type: :component do
  describe "#template" do
    let(:items) do
      [
        {title: "Section 1", content: "Content 1"},
        {title: "Section 2", content: "Content 2"},
        {title: "Section 3", content: "Content 3"}
      ]
    end

    it "renders accordion with items" do
      component = described_class.new(items: items)
      rendered = component.call

      expect(rendered).to include("Section 1")
      expect(rendered).to include("Section 2")
      expect(rendered).to include("Section 3")
    end

    it "includes Stimulus controller" do
      component = described_class.new(items: items)
      rendered = component.call

      expect(rendered).to include('data-controller="accordion"')
    end

    it "renders collapsed by default" do
      component = described_class.new(items: items)
      rendered = component.call

      expect(rendered).to include("hidden")
      expect(rendered).to include('aria-expanded="false"')
    end

    it "supports allow_multiple option" do
      component = described_class.new(items: items, allow_multiple: true)
      rendered = component.call

      expect(rendered).to include('data-accordion-allow-multiple-value="true"')
    end

    it "includes ARIA attributes for accessibility" do
      component = described_class.new(items: items)
      rendered = component.call

      expect(rendered).to include("role=\"button\"")
      expect(rendered).to include("aria-expanded")
      expect(rendered).to include("aria-controls")
    end
  end

  describe "XSS protection" do
    it "escapes HTML in titles" do
      items = [{title: "<script>alert('XSS')</script>", content: "Safe"}]
      component = described_class.new(items: items)
      rendered = component.call

      expect(rendered).not_to include("<script>")
      expect(rendered).to include("&lt;script&gt;")
    end

    it "escapes HTML in content" do
      items = [{title: "Safe", content: "<img src=x onerror=alert('XSS')>"}]
      component = described_class.new(items: items)
      rendered = component.call

      expect(rendered).not_to include("onerror=")
      expect(rendered).to include("&lt;img")
    end
  end
end
