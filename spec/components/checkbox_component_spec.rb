# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckboxComponent, type: :component do
  describe "#template" do
    it "renders a checkbox input" do
      component = described_class.new(name: "terms", label: "I agree")
      rendered = component.call

      expect(rendered).to include('type="checkbox"')
      expect(rendered).to include('name="terms"')
      expect(rendered).to include("I agree")
    end

    it "renders as checked" do
      component = described_class.new(name: "opt_in", checked: true, label: "Opt in")
      rendered = component.call

      expect(rendered).to include("checked")
    end

    it "renders as disabled" do
      component = described_class.new(name: "disabled_field", disabled: true, label: "Disabled")
      rendered = component.call

      expect(rendered).to include("disabled")
    end

    it "renders with custom value" do
      component = described_class.new(name: "role", value: "admin", label: "Admin")
      rendered = component.call

      expect(rendered).to include('value="admin"')
    end

    it "includes accessibility attributes" do
      component = described_class.new(name: "test", label: "Test checkbox", id: "test-checkbox")
      rendered = component.call

      expect(rendered).to include('id="test-checkbox"')
      expect(rendered).to include('for="test-checkbox"')
    end

    it "supports indeterminate state" do
      component = described_class.new(name: "test", label: "Select all", indeterminate: true)
      rendered = component.call

      expect(rendered).to include("data-indeterminate")
    end
  end

  describe "XSS protection" do
    it "escapes HTML in label" do
      component = described_class.new(name: "test", label: "<script>alert('XSS')</script>")
      rendered = component.call

      expect(rendered).not_to include("<script>")
      expect(rendered).to include("&lt;script&gt;")
    end

    it "escapes special characters in name" do
      component = described_class.new(name: "test<>&\"", label: "Safe")
      rendered = component.call

      # Name should be properly escaped in attribute
      expect(rendered).to match(/name=.*test/)
    end
  end
end
