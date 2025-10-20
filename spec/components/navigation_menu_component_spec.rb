# frozen_string_literal: true

require "rails_helper"

RSpec.describe NavigationMenuComponent, type: :component do
  let(:items) do
    [
      {label: "Dashboard", href: "/dashboard", icon: "📊"},
      {label: "Projects", href: "/projects"},
      {type: :separator},
      {label: "Settings", href: "/settings"}
    ]
  end

  let(:items_with_dropdown) do
    [
      {label: "Home", href: "/"},
      {
        label: "Products",
        icon: "📦",
        items: [
          {label: "All Products", href: "/products"},
          {label: "Featured", href: "/products/featured"}
        ]
      }
    ]
  end

  let(:breadcrumbs) do
    [
      {name: "Home", href: "/"},
      {name: "Projects", href: "/projects"},
      {name: "Current", href: "/projects/1"}
    ]
  end

  describe "rendering" do
    it "renders navigation menu structure" do
      render_inline(described_class.new(items: items))

      expect(page).to have_css("nav[aria-label='Main navigation']")
      expect(page).to have_css("[data-controller='navigation-menu']")
    end

    it "renders navigation items" do
      render_inline(described_class.new(items: items))

      expect(page).to have_link("Dashboard", href: "/dashboard")
      expect(page).to have_link("Projects", href: "/projects")
      expect(page).to have_link("Settings", href: "/settings")
    end

    it "renders separators" do
      render_inline(described_class.new(items: items))

      expect(page).to have_css("[role='separator']")
    end

    it "renders icons" do
      render_inline(described_class.new(items: items))

      expect(page).to have_text("📊")
    end

    it "renders badges when provided" do
      items_with_badge = [
        {label: "Notifications", href: "/notifications", badge: "5"}
      ]
      render_inline(described_class.new(items: items_with_badge))

      expect(page).to have_css(".rounded-full", text: "5")
    end
  end

  describe "breadcrumbs integration" do
    it "renders breadcrumbs when provided" do
      render_inline(described_class.new(items: items, breadcrumbs: breadcrumbs))

      expect(page).to have_css("nav[aria-label='Breadcrumb']")
      expect(page).to have_link("Home", href: "/")
      expect(page).to have_link("Projects", href: "/projects")
    end

    it "does not render breadcrumbs when not provided" do
      render_inline(described_class.new(items: items))

      expect(page).to have_no_css("nav[aria-label='Breadcrumb']")
    end
  end

  describe "active state" do
    it "highlights active items based on current path" do
      render_inline(described_class.new(items: items, current_path: "/projects"))

      projects_link = page.find_link("Projects")
      expect(projects_link[:class]).to include("bg-blue-50", "text-blue-700")
      expect(projects_link["aria-current"]).to eq("page")
    end

    it "matches path prefixes by default" do
      render_inline(described_class.new(items: items, current_path: "/projects/123"))

      projects_link = page.find_link("Projects")
      expect(projects_link[:class]).to include("bg-blue-50", "text-blue-700")
    end

    it "uses exact matching when specified" do
      items_exact = [
        {label: "Home", href: "/", match_exact: true}
      ]
      render_inline(described_class.new(items: items_exact, current_path: "/projects"))

      home_link = page.find_link("Home")
      expect(home_link[:class]).not_to include("bg-blue-50")
    end
  end

  describe "dropdown items" do
    it "renders dropdown structure" do
      render_inline(described_class.new(items: items_with_dropdown))

      expect(page).to have_button("Products")
      expect(page).to have_css("[data-controller='navigation-menu-dropdown']")
    end

    it "renders dropdown subitems" do
      render_inline(described_class.new(items: items_with_dropdown))

      expect(page).to have_link("All Products", href: "/products")
      expect(page).to have_link("Featured", href: "/products/featured")
    end

    it "renders chevron icon on dropdown trigger" do
      render_inline(described_class.new(items: items_with_dropdown))

      products_button = page.find_button("Products")
      expect(products_button).to have_css("svg")
    end

    it "has proper aria-expanded attribute" do
      render_inline(described_class.new(items: items_with_dropdown))

      products_button = page.find_button("Products")
      expect(products_button["aria-expanded"]).to eq("false")
    end
  end

  describe "orientation" do
    it "applies horizontal layout by default" do
      render_inline(described_class.new(items: items))

      nav = page.find("nav")
      expect(nav[:class]).to include("border-b")
    end

    it "applies vertical layout when specified" do
      render_inline(described_class.new(items: items, orientation: :vertical))

      nav = page.find("nav")
      expect(nav[:class]).to include("flex-col")
    end
  end

  describe "accessibility" do
    it "has proper aria-label on nav" do
      render_inline(described_class.new(items: items))

      nav = page.find("nav")
      expect(nav["aria-label"]).to eq("Main navigation")
    end

    it "has aria-current on active items" do
      render_inline(described_class.new(items: items, current_path: "/dashboard"))

      dashboard_link = page.find_link("Dashboard")
      expect(dashboard_link["aria-current"]).to eq("page")
    end

    it "does not have aria-current on inactive items" do
      render_inline(described_class.new(items: items, current_path: "/dashboard"))

      projects_link = page.find_link("Projects")
      expect(projects_link["aria-current"]).to be_nil
    end
  end

  describe "stimulus integration" do
    it "has navigation-menu controller" do
      render_inline(described_class.new(items: items))

      expect(page).to have_css("[data-controller='navigation-menu']")
    end

    it "has navigation-menu-dropdown controller on dropdown items" do
      render_inline(described_class.new(items: items_with_dropdown))

      expect(page).to have_css("[data-controller='navigation-menu-dropdown']")
    end
  end

  describe "disabled items" do
    it "applies disabled styling" do
      items_with_disabled = [
        {label: "Coming Soon", href: "/coming-soon", disabled: true}
      ]
      render_inline(described_class.new(items: items_with_disabled))

      coming_soon_link = page.find_link("Coming Soon")
      expect(coming_soon_link[:class]).to include("cursor-not-allowed")
    end
  end

  describe "headings" do
    it "renders heading items" do
      items_with_heading = [
        {type: :heading, label: "Main Menu"},
        {label: "Dashboard", href: "/dashboard"}
      ]
      render_inline(described_class.new(items: items_with_heading))

      expect(page).to have_css(".uppercase", text: "MAIN MENU")
    end
  end

  describe "separator orientation" do
    it "renders vertical separators in horizontal layout" do
      render_inline(described_class.new(items: items, orientation: :horizontal))

      separator = page.find("[role='separator']")
      expect(separator[:class]).to include("h-6", "w-px")
    end

    it "renders horizontal separators in vertical layout" do
      render_inline(described_class.new(items: items, orientation: :vertical))

      separator = page.find("[role='separator']")
      expect(separator[:class]).to include("h-px")
    end
  end
end
