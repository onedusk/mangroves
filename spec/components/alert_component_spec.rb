# frozen_string_literal: true

require "rails_helper"

RSpec.describe AlertComponent, type: :component do
  describe "#template" do
    it "renders an alert with default info type" do
      component = described_class.new("Test message")
      rendered = component.call

      expect(rendered).to include("Test message")
      expect(rendered).to include("bg-blue-100")
      expect(rendered).to include("text-blue-800")
    end

    it "renders a success alert" do
      component = described_class.new("Success message", type: :success)
      rendered = component.call

      expect(rendered).to include("Success message")
      expect(rendered).to include("bg-green-100")
      expect(rendered).to include("text-green-800")
    end

    it "renders an error alert" do
      component = described_class.new("Error message", type: :error)
      rendered = component.call

      expect(rendered).to include("Error message")
      expect(rendered).to include("bg-red-100")
      expect(rendered).to include("text-red-800")
    end

    it "renders a warning alert" do
      component = described_class.new("Warning message", type: :warning)
      rendered = component.call

      expect(rendered).to include("Warning message")
      expect(rendered).to include("bg-yellow-100")
      expect(rendered).to include("text-yellow-800")
    end

    it "includes proper structure classes" do
      component = described_class.new("Test")
      rendered = component.call

      expect(rendered).to include("p-4")
      expect(rendered).to include("rounded-md")
    end
  end

  describe "XSS protection" do
    it "escapes HTML in message" do
      malicious_message = "<script>alert('XSS')</script>"
      component = described_class.new(malicious_message)
      rendered = component.call

      expect(rendered).not_to include("<script>")
      expect(rendered).to include("&lt;script&gt;")
    end

    it "escapes special characters" do
      message_with_chars = "Message with <>&\" characters"
      component = described_class.new(message_with_chars)
      rendered = component.call

      expect(rendered).to include("&lt;")
      expect(rendered).to include("&gt;")
      expect(rendered).to include("&amp;")
    end
  end
end
