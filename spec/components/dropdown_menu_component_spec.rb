# frozen_string_literal: true

require "rails_helper"

RSpec.describe DropdownMenuComponent, type: :component do
  let(:basic_items) do
    [
      {label: "Profile", href: "/profile"},
      {label: "Settings", href: "/settings"},
      {type: :separator},
      {label: "Logout", href: "/logout", destructive: true}
    ]
  end

  let(:nested_items) do
    [
      {
        label: "File",
        items: [
          {label: "New", href: "/new", shortcut: "Cmd+N"},
          {label: "Open", href: "/open", shortcut: "Cmd+O"}
        ]
      },
      {label: "Edit", href: "/edit"}
    ]
  end

  describe "rendering" do
    it "renders basic dropdown menu structure" do
      render_inline(described_class.new(items: basic_items, trigger_text: "Menu"))

      expect(page).to have_css("[data-controller='dropdown-menu']")
      expect(page).to have_button("Menu")
      expect(page).to have_css("[role='menu']")
    end

    it "renders menu items" do
      render_inline(described_class.new(items: basic_items))

      expect(page).to have_link("Profile", href: "/profile")
      expect(page).to have_link("Settings", href: "/settings")
      expect(page).to have_link("Logout", href: "/logout")
    end

    it "renders separators" do
      render_inline(described_class.new(items: basic_items))

      expect(page).to have_css("[role='separator']")
    end

    it "applies destructive styles to destructive items" do
      render_inline(described_class.new(items: basic_items))

      logout_link = page.find_link("Logout")
      expect(logout_link[:class]).to include("text-red-600")
    end

    it "renders disabled items" do
      items = [{label: "Disabled", href: "/disabled", disabled: true}]
      render_inline(described_class.new(items: items))

      disabled_link = page.find_link("Disabled")
      expect(disabled_link[:class]).to include("cursor-not-allowed")
    end
  end

  describe "nested submenus" do
    it "renders submenu items" do
      render_inline(described_class.new(items: nested_items))

      expect(page).to have_button("File")
      expect(page).to have_link("New", href: "/new")
      expect(page).to have_link("Open", href: "/open")
    end

    it "renders keyboard shortcuts" do
      render_inline(described_class.new(items: nested_items))

      expect(page).to have_css("kbd", text: "Cmd+N")
      expect(page).to have_css("kbd", text: "Cmd+O")
    end

    it "renders chevron icon for submenus" do
      render_inline(described_class.new(items: nested_items))

      file_button = page.find_button("File")
      expect(file_button).to have_css("svg")
    end
  end

  describe "headings" do
    it "renders heading items" do
      items = [
        {type: :heading, label: "Account"},
        {label: "Profile", href: "/profile"}
      ]
      render_inline(described_class.new(items: items))

      expect(page).to have_css(".uppercase", text: "ACCOUNT")
    end
  end

  describe "alignment" do
    it "applies left alignment by default" do
      render_inline(described_class.new(items: basic_items))

      menu = page.find("[role='menu']")
      expect(menu[:class]).to include("left-0")
    end

    it "applies right alignment when specified" do
      render_inline(described_class.new(items: basic_items, align: :right))

      menu = page.find("[role='menu']")
      expect(menu[:class]).to include("right-0")
    end
  end

  describe "accessibility" do
    it "has proper ARIA attributes on trigger" do
      render_inline(described_class.new(items: basic_items))

      trigger = page.find_button("Menu")
      expect(trigger["aria-haspopup"]).to eq("true")
      expect(trigger["aria-expanded"]).to eq("false")
    end

    it "has proper role on menu" do
      render_inline(described_class.new(items: basic_items))

      menu = page.find("[role='menu']", visible: :all)
      expect(menu["aria-orientation"]).to eq("vertical")
    end

    it "has menuitem role on items" do
      render_inline(described_class.new(items: basic_items))

      expect(page).to have_css("[role='menuitem']", count: 3)
    end

    it "has proper tabindex on items" do
      render_inline(described_class.new(items: basic_items))

      page.all("[role='menuitem']").find_each do |item|
        expect(item["tabindex"]).to eq("-1")
      end
    end
  end

  describe "stimulus integration" do
    it "has dropdown-menu controller" do
      render_inline(described_class.new(items: basic_items))

      expect(page).to have_css("[data-controller='dropdown-menu']")
    end

    it "has toggle action on trigger" do
      render_inline(described_class.new(items: basic_items))

      trigger = page.find_button("Menu")
      expect(trigger["data-action"]).to include("click->dropdown-menu#toggle")
    end

    it "has keyboard action on trigger" do
      render_inline(described_class.new(items: basic_items))

      trigger = page.find_button("Menu")
      expect(trigger["data-action"]).to include("keydown->dropdown-menu#handleTriggerKeydown")
    end

    it "has keyboard action on menu" do
      render_inline(described_class.new(items: basic_items))

      menu = page.find("[role='menu']", visible: :all)
      expect(menu["data-action"]).to include("keydown->dropdown-menu#handleMenuKeydown")
    end
  end

  describe "custom width" do
    it "applies custom width" do
      render_inline(described_class.new(items: basic_items, width: "w-96"))

      menu = page.find("[role='menu']", visible: :all)
      expect(menu[:class]).to include("w-96")
    end

    it "uses default width when not specified" do
      render_inline(described_class.new(items: basic_items))

      menu = page.find("[role='menu']", visible: :all)
      expect(menu[:class]).to include("w-56")
    end
  end

  describe "icons" do
    it "renders icons when provided" do
      items = [{label: "Profile", href: "/profile", icon: "👤"}]
      render_inline(described_class.new(items: items))

      expect(page).to have_text("👤")
    end
  end
end
