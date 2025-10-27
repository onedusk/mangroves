# frozen_string_literal: true

require "rails_helper"

# NOTE: Comprehensive XSS Protection Test Suite for all Phlex components
# Tests malicious payloads against all user-controlled content rendering
RSpec.describe "XSS Protection", type: :component do
  # Common XSS attack vectors
  let(:xss_payloads) do
    [
      '<script>alert("XSS")</script>',
      '<img src=x onerror=alert("XSS")>',
      'javascript:alert("XSS")',
      '<svg onload=alert("XSS")>',
      '"><script>alert("XSS")</script>',
      "';alert('XSS');//",
      '<iframe src="javascript:alert(\'XSS\')">',
      '<body onload=alert("XSS")>',
      '<input onfocus=alert("XSS") autofocus>',
      '<marquee onstart=alert("XSS")>',
      'data:text/html,<script>alert("XSS")</script>',
      'vbscript:msgbox("XSS")',
      '<a href="javascript:alert(\'XSS\')">Click</a>',
      '<style>@import"javascript:alert(\'XSS\')";</style>',
      '<link rel="stylesheet" href="javascript:alert(\'XSS\')">',
      '<!--#exec cmd="/bin/cat /etc/passwd"-->',
      '<meta http-equiv="refresh" content="0;url=javascript:alert(\'XSS\')">',
      '<object data="javascript:alert(\'XSS\')">',
      '<embed src="javascript:alert(\'XSS\')">',
      '<base href="javascript:alert(\'XSS\')//>">'
    ]
  end

  let(:safe_url_xss_payloads) do
    [
      'javascript:alert("XSS")',
      'data:text/html,<script>alert("XSS")</script>',
      'vbscript:msgbox("XSS")',
      ' javascript:alert("XSS")',
      "\tjavascript:alert('XSS')",
      'JAVASCRIPT:alert("XSS")',
      "file:///etc/passwd"
    ]
  end

  describe ApplicationComponent do
    describe "#sanitize_text" do
      let(:component) { described_class.new }

      it "escapes HTML tags" do
        result = component.send(:sanitize_text, '<script>alert("XSS")</script>')
        expect(result).to eq("&lt;script&gt;alert(&quot;XSS&quot;)&lt;/script&gt;")
        expect(result).not_to include("<script>")
      end

      it "escapes all XSS payloads" do
        xss_payloads.each do |payload|
          result = component.send(:sanitize_text, payload)
          # Should not contain executable script tags
          expect(result).not_to include("<script>")
          # NOTE: "javascript:" may appear as escaped text which is safe
          # The key check is that dangerous patterns are properly escaped
          expect(result).not_to match(/<[^>]+on\w+\s*=/)
        end
      end

      it "handles nil input" do
        expect(component.send(:sanitize_text, nil)).to eq("")
      end

      it "converts non-string values" do
        expect(component.send(:sanitize_text, 123)).to eq("123")
      end
    end

    describe "#safe_url" do
      let(:component) { described_class.new }

      it "blocks javascript: URLs" do
        expect(component.send(:safe_url, "javascript:alert('XSS')")).to be_nil
      end

      it "blocks data: URLs" do
        expect(component.send(:safe_url, "data:text/html,<script>alert('XSS')</script>")).to be_nil
      end

      it "blocks vbscript: URLs" do
        expect(component.send(:safe_url, "vbscript:msgbox('XSS')")).to be_nil
      end

      it "blocks file: URLs" do
        expect(component.send(:safe_url, "file:///etc/passwd")).to be_nil
      end

      it "blocks all dangerous URL schemes" do
        safe_url_xss_payloads.each do |payload|
          result = component.send(:safe_url, payload)
          expect(result).to be_nil, "Expected #{payload.inspect} to be blocked"
        end
      end

      it "allows safe HTTP URLs" do
        result = component.send(:safe_url, "https://example.com/path")
        expect(result).not_to be_nil
      end

      it "allows relative URLs" do
        result = component.send(:safe_url, "/path/to/resource")
        expect(result).not_to be_nil
      end

      it "handles nil input" do
        expect(component.send(:safe_url, nil)).to be_nil
      end
    end
  end

  describe "Form Components" do
    describe InputComponent do
      it "escapes XSS in label" do
        dangerous_payload = '<script>alert("XSS")</script>'
        component = InputComponent.new(name: "test", label: dangerous_payload)
        html = component.call
        # Should see escaped version, not executable version
        expect(html).not_to match(/<script[^>]*>/)
        expect(html).to include("&lt;script&gt;")
      end

      it "escapes XSS in hint" do
        xss_payloads.each do |payload|
          component = InputComponent.new(name: "test", hint: payload)
          html = component.call
          expect(html).not_to include("<script>")
        end
      end

      it "escapes XSS in error_message" do
        xss_payloads.each do |payload|
          component = InputComponent.new(name: "test", error_message: payload)
          html = component.call
          expect(html).not_to include("<script>")
        end
      end
    end

    describe TextareaComponent do
      it "escapes XSS in label, hint, and error_message" do
        dangerous_payload = '<script>alert("XSS")</script>'
        component = TextareaComponent.new(
          name: "test",
          label: dangerous_payload,
          hint: dangerous_payload,
          error_message: dangerous_payload
        )
        html = component.call
        # Should not have executable script tags
        expect(html).not_to match(/<script[^>]*>/)
        # Should have escaped version
        expect(html).to include("&lt;script&gt;")
      end
    end

    describe SelectComponent do
      it "escapes XSS in options" do
        options = xss_payloads.map { |p| {value: "test", label: p} }
        component = SelectComponent.new(name: "test", options: options)
        html = component.call
        expect(html).not_to include("<script>")
      end

      it "escapes XSS in placeholder" do
        component = SelectComponent.new(
          name: "test",
          options: [],
          placeholder: '<script>alert("XSS")</script>'
        )
        html = component.call
        expect(html).not_to include("<script>")
      end
    end

    describe LabelComponent do
      it "escapes XSS in text" do
        xss_payloads.each do |payload|
          component = LabelComponent.new(text: payload, for_id: "test")
          html = component.call
          expect(html).not_to include("<script>")
        end
      end

      it "escapes XSS in tooltip" do
      dangerous_payload = '<script>alert("XSS")</script>'
      component = LabelComponent.new(text: "Test", for_id: "test", tooltip: dangerous_payload)
      html = component.call
      # Should see escaped version in data attribute
      expect(html).not_to match(/<script[^>]*>/)
      expect(html).to include("&lt;script&gt;")
    end
  end
  end

  describe "Notification Components" do
    describe ToastComponent do
      it "escapes XSS in message" do
        xss_payloads.each do |payload|
          component = ToastComponent.new(message: payload)
          html = component.call
          expect(html).not_to include("<script>")
          # NOTE: Check for executable event handlers, not escaped text
          expect(html).not_to match(/<[^>]+on\w+\s*=\s*alert/)
        end
      end
    end

    describe SonnerComponent do
      it "escapes XSS in message" do
        xss_payloads.each do |payload|
          component = SonnerComponent.new(message: payload)
          html = component.call
          expect(html).not_to include("<script>")
        end
      end

      it "blocks dangerous URLs in action_url" do
        safe_url_xss_payloads.each do |payload|
          component = SonnerComponent.new(
            message: "Test",
            action_label: "Click",
            action_url: payload
          )
          html = component.call
          expect(html).not_to include('href="javascript:')
          expect(html).not_to include('href="data:')
        end
      end

      it "escapes XSS in action_label" do
        component = SonnerComponent.new(
          message: "Test",
          action_label: '<script>alert("XSS")</script>',
          action_url: "/safe"
        )
        html = component.call
        expect(html).not_to include("<script>")
      end
    end
  end

  describe "Menu Components" do
    describe DropdownMenuComponent do
      it "escapes XSS in trigger_text" do
        xss_payloads.each do |payload|
          component = DropdownMenuComponent.new(items: [], trigger_text: payload)
          html = component.call
          expect(html).not_to include("<script>")
        end
      end

      it "escapes XSS in menu item labels" do
        items = xss_payloads.map { |p| {label: p, href: "/safe"} }
        component = DropdownMenuComponent.new(items: items)
        html = component.call
        expect(html).not_to include("<script>")
      end

      it "escapes XSS in shortcuts" do
        items = [{label: "Test", href: "/safe", shortcut: '<script>alert("XSS")</script>'}]
        component = DropdownMenuComponent.new(items: items)
        html = component.call
        expect(html).not_to include("<script>")
      end

      it "escapes XSS in heading labels" do
        items = [{type: :heading, label: '<script>alert("XSS")</script>'}]
        component = DropdownMenuComponent.new(items: items)
        html = component.call
        expect(html).not_to include("<script>")
      end
    end

    describe PopoverComponent do
      it "escapes XSS in trigger_content" do
        xss_payloads.each do |payload|
          component = PopoverComponent.new(trigger_content: payload) {}
          html = component.call
          expect(html).not_to include("<script>")
        end
      end
    end
  end

  describe "Display Components" do
    describe HeroComponent do
      it "escapes XSS in title" do
        xss_payloads.each do |payload|
          component = HeroComponent.new(title: payload)
          html = component.call
          expect(html).not_to include("<script>")
        end
      end

      it "escapes XSS in subtitle" do
        xss_payloads.each do |payload|
          component = HeroComponent.new(title: "Test", subtitle: payload)
          html = component.call
          expect(html).not_to include("<script>")
        end
      end

      it "blocks dangerous background image URLs" do
        safe_url_xss_payloads.each do |payload|
          component = HeroComponent.new(title: "Test", background_image: payload)
          html = component.call
          expect(html).not_to include("url(javascript:")
          expect(html).not_to include("url(data:")
        end
      end

      it "blocks dangerous URLs in CTAs" do
        component = HeroComponent.new(
          title: "Test",
          primary_cta: {text: "Click", url: "javascript:alert('XSS')"}
        )
        html = component.call
        expect(html).not_to include('href="javascript:')
      end

      it "escapes XSS in CTA text" do
        component = HeroComponent.new(
          title: "Test",
          primary_cta: {text: '<script>alert("XSS")</script>', url: "/safe"}
        )
        html = component.call
        expect(html).not_to include("<script>")
      end
    end

    describe FooterComponent do
      it "escapes XSS in account name" do
        account = double("Account", name: '<script>alert("XSS")</script>', settings: {})
        component = FooterComponent.new(account: account)
        html = component.call
        expect(html).not_to include("<script>")
      end

      it "escapes XSS in footer description" do
        account = double(
          "Account",
          name: "Test",
          settings: {"footer_description" => '<script>alert("XSS")</script>'}
        )
        component = FooterComponent.new(account: account)
        html = component.call
        expect(html).not_to include("<script>")
      end

      it "blocks dangerous logo URLs" do
        component = FooterComponent.new(logo_url: "javascript:alert('XSS')")
        html = component.call
        expect(html).not_to include('src="javascript:')
      end

      it "escapes XSS in column titles and links" do
        columns = [
          {
            title: '<script>alert("XSS")</script>',
            links: [
              {text: '<img src=x onerror=alert("XSS")>', url: "/safe"}
            ]
          }
        ]
        component = FooterComponent.new(columns: columns)
        html = component.call
        # Should not have executable script tags or event handlers
        expect(html).not_to match(/<script[^>]*>/)
        expect(html).not_to match(/<img[^>]+onerror\s*=/)
      end

      it "blocks dangerous social link URLs" do
        social_links = [
          {url: "javascript:alert('XSS')", label: "Test", icon: :twitter}
        ]
        component = FooterComponent.new(social_links: social_links)
        html = component.call
        expect(html).not_to include('href="javascript:')
      end

      it "escapes XSS in copyright text" do
        component = FooterComponent.new(copyright_text: '<script>alert("XSS")</script>')
        html = component.call
        expect(html).not_to include("<script>")
      end
    end
  end

  describe "Edge Cases and Complex Scenarios" do
    it "handles nested XSS attempts in multiple fields" do
      component = InputComponent.new(
        name: "test",
        label: '<script>alert("1")</script>',
        hint: '<img src=x onerror=alert("2")>',
        error_message: 'javascript:alert("3")'
      )
      html = component.call
      # Should not have executable scripts or event handlers
      expect(html).not_to match(/<script[^>]*>/)
      expect(html).not_to match(/<img[^>]+onerror\s*=/)
    end

    it "handles Unicode and encoded XSS attempts" do
      unicode_xss = [
        "\u003cscript\u003ealert('XSS')\u003c/script\u003e",
        "&#60;script&#62;alert('XSS')&#60;/script&#62;",
        "%3Cscript%3Ealert('XSS')%3C/script%3E"
      ]

      unicode_xss.each do |payload|
        component = ToastComponent.new(message: payload)
        html = component.call
        # Even encoded, should not execute
        expect(html).not_to match(/<script[^>]*>/)
      end
    end

    it "handles XSS in proc content" do
      # Test that proc content is executed in component context
      component = PopoverComponent.new(trigger_content: "Safe text") {}
      html = component.call
      # Proc should be executed safely without raw HTML injection
      expect(html).to be_a(String)
      expect(html).to include("Safe text")
    end

    it "protects against attribute-based XSS" do
      # Attempts to break out of attributes
      payloads = [
        '" onload="alert(\'XSS\')"',
        '\' onmouseover="alert(\'XSS\')"',
        '"><svg onload=alert("XSS")><"'
      ]

      payloads.each do |payload|
        component = InputComponent.new(name: "test", label: payload)
        html = component.call
        # The key is that event handlers should NOT be executable
        # Check that there are no unescaped event handlers that could execute
        # The pattern should be looking for actual HTML tags with event handlers, not escaped text
        expect(html).not_to match(/<svg[^>]+onload\s*=\s*alert[^>]*>/)
        expect(html).not_to match(/<\w+[^>]+on\w+\s*=\s*(?:"|')alert/)
      end
    end
  end
end
