# frozen_string_literal: true

require "rails_helper"

RSpec.describe NavigationComponent, type: :component do
  let(:user) { create(:user) }

  describe "rendering" do
    it "renders basic navigation" do
      output = render_inline(described_class.new)
      html = output.to_html

      expect(html).to include("nav")
      expect(html).to include("border-b border-gray-200")
    end

    it "renders with sticky positioning" do
      output = render_inline(described_class.new(sticky: true))
      html = output.to_html

      expect(html).to include("sticky")
      expect(html).to include("top-0")
    end

    it "renders without sticky positioning" do
      output = render_inline(described_class.new(sticky: false))
      html = output.to_html

      expect(html).not_to include("sticky")
    end

    it "renders with transparent background" do
      output = render_inline(described_class.new(transparent: true))
      expect(output.to_html).to include("bg-transparent")
    end
  end

  describe "logo section" do
    it "renders logo URL" do
      output = render_inline(described_class.new(logo_url: "https://example.com/logo.png"))
      html = output.to_html

      expect(html).to include("https://example.com/logo.png")
      expect(html).to include('alt="Logo"')
    end

    it "renders logo text" do
      output = render_inline(described_class.new(logo_text: "MyApp"))
      expect(output.to_html).to include("MyApp")
    end

    it "renders account name as fallback" do
      account = create(:account, name: "Acme Corp")
      output = render_inline(described_class.new(account: account))
      expect(output.to_html).to include("Acme Corp")
    end

    it "renders default text when no branding provided" do
      output = render_inline(described_class.new)
      expect(output.to_html).to include("App")
    end
  end

  describe "menu items" do
    let(:menu_items) do
      [
        {text: "Home", url: "/"},
        {text: "About", url: "/about"},
        {text: "Contact", url: "/contact"}
      ]
    end

    it "renders simple menu items" do
      output = render_inline(described_class.new(menu_items: menu_items))
      html = output.to_html

      expect(html).to include("Home")
      expect(html).to include("About")
      expect(html).to include("Contact")
      expect(html).to include('href="/"')
      expect(html).to include('href="/about"')
      expect(html).to include('href="/contact"')
    end

    it "renders dropdown menu with children" do
      menu_with_dropdown = [
        {
          text: "Products",
          url: "#",
          children: [
            {text: "Product A", url: "/products/a"},
            {text: "Product B", url: "/products/b"}
          ]
        }
      ]

      output = render_inline(described_class.new(menu_items: menu_with_dropdown))
      html = output.to_html

      expect(html).to include("Products")
      expect(html).to include("Product A")
      expect(html).to include("Product B")
      expect(html).to include("data-controller=\"dropdown\"")
    end
  end

  describe "user authentication state" do
    it "renders sign in and sign up buttons when not authenticated" do
      output = render_inline(described_class.new(current_user: nil))
      html = output.to_html

      expect(html).to include("Sign in")
      expect(html).to include("Sign up")
    end

    it "renders user dropdown when authenticated" do
      output = render_inline(described_class.new(current_user: user))
      html = output.to_html

      expect(html).to include(user.email)
      expect(html).not_to include("Sign in")
    end

    it "renders user menu items" do
      output = render_inline(described_class.new(current_user: user))
      html = output.to_html

      expect(html).to include("Profile")
      expect(html).to include("Settings")
      expect(html).to include("Sign out")
    end
  end

  describe "tenant context" do
    it "displays account name when provided" do
      account = create(:account, name: "Test Company")
      output = render_inline(described_class.new(account: account))
      expect(output.to_html).to include("Test Company")
    end

    it "works without account context" do
      output = render_inline(described_class.new)
      html = output.to_html

      expect(html).to include("nav")
      expect(html).not_to include("undefined")
    end
  end

  describe "responsive behavior" do
    it "renders mobile menu button" do
      output = render_inline(described_class.new)
      html = output.to_html

      expect(html).to include("md:hidden")
      expect(html).to include("data-action=\"click->navigation#toggleMobile\"")
    end

    it "renders mobile menu" do
      menu_items = [
        {text: "Home", url: "/"},
        {text: "About", url: "/about"}
      ]

      output = render_inline(described_class.new(menu_items: menu_items))
      html = output.to_html

      expect(html).to include("data-navigation-target=\"mobileMenu\"")
    end

    it "hides desktop menu on mobile" do
      output = render_inline(described_class.new)
      html = output.to_html

      expect(html).to include("hidden md:flex")
    end
  end

  describe "stimulus controllers" do
    it "includes navigation controller" do
      output = render_inline(described_class.new)
      expect(output.to_html).to include("data-controller=\"navigation\"")
    end

    it "includes dropdown controllers for menus" do
      menu_with_dropdown = [
        {
          text: "Products",
          url: "#",
          children: [{text: "Item", url: "/item"}]
        }
      ]

      output = render_inline(described_class.new(menu_items: menu_with_dropdown))
      expect(output.to_html).to include("data-controller=\"dropdown\"")
    end
  end
end
