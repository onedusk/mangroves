# frozen_string_literal: true

require "rails_helper"

RSpec.describe MenubarComponent, type: :component do
  let(:menus) do
    [
      {
        label: "File",
        items: [
          {label: "New", href: "/new", shortcut: "Cmd+N"},
          {label: "Open", href: "/open", shortcut: "Cmd+O"},
          {type: :separator},
          {label: "Exit", href: "/exit"}
        ]
      },
      {
        label: "Edit",
        items: [
          {label: "Cut", href: "/cut", shortcut: "Cmd+X"},
          {label: "Copy", href: "/copy", shortcut: "Cmd+C"},
          {label: "Paste", href: "/paste", shortcut: "Cmd+V"}
        ]
      },
      {
        label: "View",
        items: [
          {label: "Zoom In", href: "/zoom-in"},
          {label: "Zoom Out", href: "/zoom-out"}
        ]
      }
    ]
  end

  describe "rendering" do
    it "renders menubar structure" do
      render_inline(described_class.new(menus: menus))

      expect(page).to have_css("nav[role='menubar']")
      expect(page).to have_css("[data-controller='menubar']")
    end

    it "renders all menu triggers" do
      render_inline(described_class.new(menus: menus))

      expect(page).to have_button("File")
      expect(page).to have_button("Edit")
      expect(page).to have_button("View")
    end

    it "renders menu items in dropdowns" do
      render_inline(described_class.new(menus: menus))

      expect(page).to have_link("New", href: "/new")
      expect(page).to have_link("Cut", href: "/cut")
      expect(page).to have_link("Zoom In", href: "/zoom-in")
    end

    it "renders keyboard shortcuts" do
      render_inline(described_class.new(menus: menus))

      expect(page).to have_css("kbd", text: "Cmd+N")
      expect(page).to have_css("kbd", text: "Cmd+X")
    end

    it "renders separators in menus" do
      render_inline(described_class.new(menus: menus))

      expect(page).to have_css("[role='separator']")
    end
  end

  describe "accessibility" do
    it "has menubar role on nav" do
      render_inline(described_class.new(menus: menus))

      nav = page.find("nav")
      expect(nav["role"]).to eq("menubar")
      expect(nav["aria-label"]).to eq("Main menu")
    end

    it "has menuitem role on triggers" do
      render_inline(described_class.new(menus: menus))

      triggers = page.all("button[role='menuitem']")
      expect(triggers.count).to eq(3)
    end

    it "has proper ARIA attributes on triggers" do
      render_inline(described_class.new(menus: menus))

      file_trigger = page.find_button("File")
      expect(file_trigger["aria-haspopup"]).to eq("true")
      expect(file_trigger["aria-expanded"]).to eq("false")
    end

    it "has menu role on dropdowns" do
      render_inline(described_class.new(menus: menus))

      expect(page).to have_css("[role='menu']", count: 3, visible: :all)
    end

    it "has vertical orientation on dropdown menus" do
      render_inline(described_class.new(menus: menus))

      page.all("[role='menu']", visible: :all).each do |menu|
        expect(menu["aria-orientation"]).to eq("vertical")
      end
    end
  end

  describe "stimulus integration" do
    it "has menubar controller" do
      render_inline(described_class.new(menus: menus))

      expect(page).to have_css("[data-controller='menubar']")
    end

    it "has dropdown-menu controller on each menu" do
      render_inline(described_class.new(menus: menus))

      expect(page).to have_css("[data-controller='dropdown-menu']", count: 3)
    end

    it "has hover action on triggers" do
      render_inline(described_class.new(menus: menus))

      file_trigger = page.find_button("File")
      expect(file_trigger["data-action"]).to include("mouseenter->menubar#handleHover")
    end

    it "has focus action on triggers" do
      render_inline(described_class.new(menus: menus))

      file_trigger = page.find_button("File")
      expect(file_trigger["data-action"]).to include("focus->menubar#handleFocus")
    end
  end

  describe "styling" do
    it "has border bottom on menubar" do
      render_inline(described_class.new(menus: menus))

      nav = page.find("nav[role='menubar']")
      expect(nav[:class]).to include("border-b")
    end

    it "has proper trigger styling" do
      render_inline(described_class.new(menus: menus))

      trigger = page.find_button("File")
      expect(trigger[:class]).to include("hover:bg-gray-100")
      expect(trigger[:class]).to include("focus:bg-gray-100")
    end
  end

  describe "with headings" do
    it "renders heading items" do
      menus_with_headings = [
        {
          label: "File",
          items: [
            {type: :heading, label: "Recent"},
            {label: "Document 1", href: "/doc1"}
          ]
        }
      ]
      render_inline(described_class.new(menus: menus_with_headings))

      expect(page).to have_css(".uppercase", text: "Recent")
    end
  end

  describe "with destructive items" do
    it "applies destructive styling" do
      menus_with_destructive = [
        {
          label: "File",
          items: [
            {label: "Delete", href: "/delete", destructive: true}
          ]
        }
      ]
      render_inline(described_class.new(menus: menus_with_destructive))

      delete_link = page.find_link("Delete")
      expect(delete_link[:class]).to include("text-red-600")
    end
  end

  describe "with disabled items" do
    it "applies disabled styling" do
      menus_with_disabled = [
        {
          label: "Edit",
          items: [
            {label: "Undo", href: "/undo", disabled: true}
          ]
        }
      ]
      render_inline(described_class.new(menus: menus_with_disabled))

      undo_link = page.find_link("Undo")
      expect(undo_link[:class]).to include("cursor-not-allowed")
    end
  end
end
