# frozen_string_literal: true

require "rails_helper"

RSpec.describe TextareaComponent, type: :component do
  describe "#template" do
    it "renders a textarea" do
      component = described_class.new(name: "comment")
      rendered = component.call

      expect(rendered).to include("textarea")
      expect(rendered).to include('name="comment"')
    end

    it "renders with value" do
      component = described_class.new(name: "bio", value: "Hello world")
      rendered = component.call

      expect(rendered).to include("Hello world")
    end

    it "renders with placeholder" do
      component = described_class.new(name: "message", placeholder: "Enter your message...")
      rendered = component.call

      expect(rendered).to include('placeholder="Enter your message..."')
    end

    it "renders with custom row count" do
      component = described_class.new(name: "description", rows: 5)
      rendered = component.call

      expect(rendered).to include('rows="5"')
    end

    it "renders with max length" do
      component = described_class.new(name: "tweet", max_length: 280)
      rendered = component.call

      expect(rendered).to include('maxlength="280"')
    end

    it "renders character counter when show_count is true" do
      component = described_class.new(name: "bio", max_length: 500, show_count: true)
      rendered = component.call

      expect(rendered).to include("data-textarea-show-count-value=\"true\"")
    end

    it "renders as required" do
      component = described_class.new(name: "required_text", required: true, label: "Required")
      rendered = component.call

      expect(rendered).to include("required")
      expect(rendered).to include("*")
    end

    it "renders as disabled" do
      component = described_class.new(name: "disabled_text", disabled: true)
      rendered = component.call

      expect(rendered).to include("disabled")
    end

    it "renders with label" do
      component = described_class.new(name: "description", label: "Description")
      rendered = component.call

      expect(rendered).to include("Description")
      expect(rendered).to include("label")
    end

    it "renders with hint text" do
      component = described_class.new(name: "bio", hint: "Tell us about yourself")
      rendered = component.call

      expect(rendered).to include("Tell us about yourself")
    end

    it "renders with error message" do
      component = described_class.new(
        name: "comment",
        validation_state: :error,
        error_message: "Comment is too short"
      )
      rendered = component.call

      expect(rendered).to include("Comment is too short")
      expect(rendered).to include("text-red-600")
    end

    it "includes Stimulus controller" do
      component = described_class.new(name: "test")
      rendered = component.call

      expect(rendered).to include('data-controller="textarea"')
    end

    it "includes proper ARIA attributes" do
      component = described_class.new(
        name: "test",
        required: true,
        label: "Test Field",
        hint: "Helper text"
      )
      rendered = component.call

      expect(rendered).to include("aria-required").or include("required")
      expect(rendered).to include("aria-describedby")
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
  end
end
