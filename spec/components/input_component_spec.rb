# frozen_string_literal: true

require "rails_helper"

RSpec.describe InputComponent, type: :component do
  describe "#template" do
    it "renders a text input" do
      component = described_class.new(name: "email", type: :email)
      rendered = component.call

      expect(rendered).to include('type="email"')
      expect(rendered).to include('name="email"')
    end

    it "renders with value" do
      component = described_class.new(name: "username", value: "john_doe")
      rendered = component.call

      expect(rendered).to include('value="john_doe"')
    end

    it "renders with placeholder" do
      component = described_class.new(name: "search", placeholder: "Search...")
      rendered = component.call

      expect(rendered).to include('placeholder="Search..."')
    end

    it "renders as disabled" do
      component = described_class.new(name: "locked", disabled: true)
      rendered = component.call

      expect(rendered).to include("disabled")
    end

    it "renders as required" do
      component = described_class.new(name: "required_field", required: true, label: "Required")
      rendered = component.call

      expect(rendered).to include("required")
      expect(rendered).to include("*")
    end

    it "renders with label" do
      component = described_class.new(name: "name", label: "Full Name")
      rendered = component.call

      expect(rendered).to include("Full Name")
      expect(rendered).to include("label")
    end

    it "renders with hint text" do
      component = described_class.new(name: "password", hint: "Must be at least 8 characters")
      rendered = component.call

      expect(rendered).to include("Must be at least 8 characters")
    end

    it "renders with error message" do
      component = described_class.new(
        name: "email",
        validation_state: :error,
        error_message: "Email is invalid"
      )
      rendered = component.call

      expect(rendered).to include("Email is invalid")
      expect(rendered).to include("text-red-600")
    end

    it "includes Stimulus controller" do
      component = described_class.new(name: "test")
      rendered = component.call

      expect(rendered).to include('data-controller="input"')
    end

    it "includes proper ARIA attributes" do
      component = described_class.new(
        name: "test",
        required: true,
        label: "Test Field",
        hint: "Helper text"
      )
      rendered = component.call

      expect(rendered).to include("aria-required")
      expect(rendered).to include("aria-describedby")
    end

    it "applies error styling when validation fails" do
      component = described_class.new(name: "test", validation_state: :error)
      rendered = component.call

      expect(rendered).to include("border-red-300")
    end

    it "applies success styling when validation passes" do
      component = described_class.new(name: "test", validation_state: :success)
      rendered = component.call

      expect(rendered).to include("border-green-300").or include("text-green")
    end
  end

  describe "XSS protection" do
    it "escapes HTML in value" do
      component = described_class.new(name: "test", value: "<script>alert('XSS')</script>")
      rendered = component.call

      expect(rendered).not_to include("<script>")
      expect(rendered).to include("&lt;script&gt;")
    end

    it "escapes HTML in label" do
      component = described_class.new(name: "test", label: "<script>alert('XSS')</script>")
      rendered = component.call

      expect(rendered).not_to include("<script>")
      expect(rendered).to include("&lt;script&gt;")
    end

    it "escapes HTML in hint" do
      component = described_class.new(name: "test", hint: "<img src=x onerror=alert('XSS')>")
      rendered = component.call

      expect(rendered).not_to include("onerror=")
      expect(rendered).to include("&lt;img")
    end

    it "escapes HTML in error message" do
      component = described_class.new(
        name: "test",
        error_message: "<script>alert('XSS')</script>"
      )
      rendered = component.call

      expect(rendered).not_to include("<script>")
      expect(rendered).to include("&lt;script&gt;")
    end
  end
end
