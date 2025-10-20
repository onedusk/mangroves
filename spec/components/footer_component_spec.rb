# frozen_string_literal: true

require "rails_helper"

RSpec.describe FooterComponent, type: :component do
  let(:account) { create(:account, name: "Test Company") }

  describe "rendering" do
    it "renders basic footer" do
      output = render_inline(described_class.new)
      html = output.to_html

      expect(html).to include("footer")
      expect(html).to include("bg-gray-900")
      expect(html).to include("All rights reserved")
    end

    it "renders with account branding" do
      output = render_inline(described_class.new(account: account))
      html = output.to_html

      expect(html).to include(account.name)
      expect(html).to include("© #{Time.current.year} #{account.name}")
    end

    it "renders with custom copyright text" do
      copyright = "© 2024 Custom Copyright"
      output = render_inline(described_class.new(copyright_text: copyright))
      html = output.to_html

      expect(html).to include(copyright)
    end

    it "renders with logo URL" do
      output = render_inline(described_class.new(logo_url: "https://example.com/logo.png"))
      html = output.to_html

      expect(html).to include("https://example.com/logo.png")
      expect(html).to include('alt="Logo"')
    end
  end

  describe "tenant context" do
    it "displays tenant name when account is provided" do
      output = render_inline(described_class.new(account: account))
      expect(output.to_html).to include(account.name)
    end

    it "uses tenant settings for footer description" do
      account.update!(settings: {"footer_description" => "We are the best company"})
      output = render_inline(described_class.new(account: account))
      expect(output.to_html).to include("We are the best company")
    end

    it "handles missing tenant gracefully" do
      output = render_inline(described_class.new)
      html = output.to_html

      expect(html).to include("All rights reserved")
      expect(html).not_to include("undefined")
    end
  end

  describe "columns" do
    it "renders footer columns" do
      columns = [
        {
          title: "Company",
          links: [
            {text: "About", url: "/about"},
            {text: "Careers", url: "/careers"}
          ]
        },
        {
          title: "Support",
          links: [
            {text: "Help", url: "/help"},
            {text: "Contact", url: "/contact"}
          ]
        }
      ]

      output = render_inline(described_class.new(columns: columns))
      html = output.to_html

      expect(html).to include("Company")
      expect(html).to include("Support")
      expect(html).to include("About")
      expect(html).to include("Careers")
      expect(html).to include("Help")
      expect(html).to include("Contact")
    end
  end

  describe "social links" do
    it "renders social media links" do
      social_links = [
        {icon: :twitter, url: "https://twitter.com/example", label: "Twitter"},
        {icon: :github, url: "https://github.com/example", label: "GitHub"},
        {icon: :linkedin, url: "https://linkedin.com/company/example", label: "LinkedIn"}
      ]

      output = render_inline(described_class.new(social_links: social_links))
      html = output.to_html

      expect(html).to include("https://twitter.com/example")
      expect(html).to include("https://github.com/example")
      expect(html).to include("https://linkedin.com/company/example")
      expect(html).to include('aria-label="Twitter"')
    end

    it "renders no social section when empty" do
      output = render_inline(described_class.new(social_links: []))
      html = output.to_html

      expect(html).not_to include("aria-label=")
    end
  end

  describe "responsive behavior" do
    it "applies responsive grid classes" do
      output = render_inline(described_class.new)
      html = output.to_html

      expect(html).to include("grid-cols-1")
      expect(html).to include("md:grid-cols-2")
      expect(html).to include("lg:grid-cols-4")
    end

    it "applies responsive padding" do
      output = render_inline(described_class.new)
      html = output.to_html

      expect(html).to include("px-4")
      expect(html).to include("sm:px-6")
      expect(html).to include("lg:px-8")
      expect(html).to include("py-12")
      expect(html).to include("sm:py-16")
    end
  end

  describe "footer links" do
    it "renders privacy and terms links" do
      output = render_inline(described_class.new)
      html = output.to_html

      expect(html).to include("Privacy Policy")
      expect(html).to include("Terms of Service")
      expect(html).to include("/privacy")
      expect(html).to include("/terms")
    end
  end
end
