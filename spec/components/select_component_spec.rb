# frozen_string_literal: true

require "rails_helper"

RSpec.describe SelectComponent, type: :component do
  let(:options) do
    [
      {value: "1", label: "Option 1"},
      {value: "2", label: "Option 2"},
      {value: "3", label: "Option 3"}
    ]
  end

  describe "#template" do
    it "renders a select component" do
      component = described_class.new(name: "choice", options: options)
      rendered = component.call

      expect(rendered).to include("Option 1")
      expect(rendered).to include("Option 2")
      expect(rendered).to include("Option 3")
    end

    it "renders with selected option" do
      component = described_class.new(name: "choice", options: options, selected: "2")
      rendered = component.call

      expect(rendered).to include('data-value="2"')
      expect(rendered).to include("Option 2")
    end

    it "renders with placeholder" do
      component = described_class.new(name: "choice", options: options, placeholder: "Choose...")
      rendered = component.call

      expect(rendered).to include("Choose...")
    end

    it "supports multiple selection" do
      component = described_class.new(name: "choices", options: options, multiple: true)
      rendered = component.call

      expect(rendered).to include('aria-multiselectable="true"')
    end

    it "supports searchable mode" do
      component = described_class.new(name: "search", options: options, searchable: true)
      rendered = component.call

      expect(rendered).to include('type="text"')
      expect(rendered).to include("Search...")
    end

    it "includes Stimulus controller" do
      component = described_class.new(name: "test", options: options)
      rendered = component.call

      expect(rendered).to include('data-controller="select"')
    end

    it "includes proper ARIA attributes" do
      component = described_class.new(name: "test", options: options)
      rendered = component.call

      expect(rendered).to include('role="listbox"')
      expect(rendered).to include('aria-haspopup="listbox"')
      expect(rendered).to include('aria-expanded="false"')
    end

    it "renders as disabled" do
      component = described_class.new(name: "test", options: options, disabled: true)
      rendered = component.call

      expect(rendered).to include("disabled")
    end
  end

  describe "XSS protection" do
    it "escapes HTML in option labels" do
      malicious_options = [
        {value: "1", label: "<script>alert('XSS')</script>"}
      ]
      component = described_class.new(name: "test", options: malicious_options)
      rendered = component.call

      expect(rendered).not_to include("<script>")
      expect(rendered).to include("&lt;script&gt;")
    end

    it "escapes HTML in placeholder" do
      component = described_class.new(
        name: "test",
        options: options,
        placeholder: "<img src=x onerror=alert('XSS')>"
      )
      rendered = component.call

      expect(rendered).not_to include("onerror=")
      expect(rendered).to include("&lt;img")
    end
  end
end
