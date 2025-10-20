# frozen_string_literal: true

require "rails_helper"

RSpec.describe SidebarComponent, type: :component do
  let(:sections) do
    [
      {
        id: "main",
        title: "Main Menu",
        collapsible: false,
        items: [
          {label: "Dashboard", href: "/dashboard", icon: "📊", active: true},
          {label: "Projects", href: "/projects", icon: "📁"}
        ]
      },
      {
        id: "settings",
        title: "Settings",
        collapsible: true,
        expanded: true,
        items: [
          {label: "Account", href: "/settings/account"},
          {label: "Billing", href: "/settings/billing", badge: "Pro"}
        ]
      }
    ]
  end

  let(:user) { User.new(id: "user-1", email: "test@example.com") }
  let(:workspace) { Workspace.new(id: "ws-1", name: "Test Workspace") }

  describe "rendering" do
    it "renders sidebar structure" do
      render_inline(described_class.new(sections: sections))

      expect(page).to have_css("aside[aria-label='Sidebar navigation']")
      expect(page).to have_css("[data-controller='sidebar']")
    end

    it "renders header" do
      render_inline(described_class.new(sections: sections))

      expect(page).to have_css("h2", text: "Mangroves")
    end

    it "renders collapse button when collapsible" do
      render_inline(described_class.new(sections: sections, collapsible: true))

      expect(page).to have_button("Toggle sidebar")
      expect(page).to have_css("[data-sidebar-target='collapseButton']")
    end

    it "does not render collapse button when not collapsible" do
      render_inline(described_class.new(sections: sections, collapsible: false))

      expect(page).to have_no_button("Toggle sidebar")
    end

    it "renders footer" do
      render_inline(described_class.new(sections: sections))

      expect(page).to have_css("[data-sidebar-target='footer']")
    end
  end

  describe "workspace switcher" do
    it "renders workspace switcher when user and workspace provided" do
      render_inline(
        described_class.new(
          sections: sections,
          current_user: user,
          current_workspace: workspace,
          show_workspace_switcher: true
        )
      )

      # WorkspaceSwitcherComponent should be rendered
      expect(page).to have_css("[data-sidebar-target='workspaceSwitcher']")
    end

    it "does not render workspace switcher when show_workspace_switcher is false" do
      render_inline(
        described_class.new(
          sections: sections,
          current_user: user,
          current_workspace: workspace,
          show_workspace_switcher: false
        )
      )

      expect(page).to have_no_css("[data-sidebar-target='workspaceSwitcher']")
    end

    it "does not render workspace switcher when no user" do
      render_inline(
        described_class.new(
          sections: sections,
          show_workspace_switcher: true
        )
      )

      expect(page).to have_no_css("[data-sidebar-target='workspaceSwitcher']")
    end
  end

  describe "sections" do
    it "renders all sections" do
      render_inline(described_class.new(sections: sections))

      expect(page).to have_text("Main Menu")
      expect(page).to have_text("Settings")
    end

    it "renders section items" do
      render_inline(described_class.new(sections: sections))

      expect(page).to have_link("Dashboard", href: "/dashboard")
      expect(page).to have_link("Projects", href: "/projects")
      expect(page).to have_link("Account", href: "/settings/account")
      expect(page).to have_link("Billing", href: "/settings/billing")
    end

    it "renders icons" do
      render_inline(described_class.new(sections: sections))

      expect(page).to have_text("📊")
      expect(page).to have_text("📁")
    end

    it "renders badges" do
      render_inline(described_class.new(sections: sections))

      expect(page).to have_css(".rounded-full", text: "Pro")
    end
  end

  describe "collapsible sections" do
    it "renders collapsible section header as button" do
      render_inline(described_class.new(sections: sections))

      settings_header = page.find("button[data-section-id='settings']")
      expect(settings_header).to have_text("Settings")
    end

    it "renders non-collapsible section header as div" do
      render_inline(described_class.new(sections: sections))

      main_header = page.find("div", text: "Main Menu", match: :prefer_exact)
      expect(main_header.tag_name).to eq("div")
    end

    it "has proper aria-expanded on collapsible sections" do
      render_inline(described_class.new(sections: sections))

      settings_header = page.find("button[data-section-id='settings']")
      expect(settings_header["aria-expanded"]).to eq("true")
    end

    it "has chevron icon on collapsible sections" do
      render_inline(described_class.new(sections: sections))

      settings_header = page.find("button[data-section-id='settings']")
      expect(settings_header).to have_css("svg[data-sidebar-target='chevron']")
    end

    it "sets aria-expanded to false when section is not expanded" do
      sections_collapsed = [
        {
          id: "collapsed",
          title: "Collapsed",
          collapsible: true,
          expanded: false,
          items: [{label: "Item", href: "/item"}]
        }
      ]
      render_inline(described_class.new(sections: sections_collapsed))

      collapsed_header = page.find("button[data-section-id='collapsed']")
      expect(collapsed_header["aria-expanded"]).to eq("false")
    end
  end

  describe "active state" do
    it "highlights active navigation items" do
      render_inline(described_class.new(sections: sections))

      dashboard_link = page.find_link("Dashboard")
      expect(dashboard_link[:class]).to include("bg-blue-50", "text-blue-700")
      expect(dashboard_link["aria-current"]).to eq("page")
    end

    it "does not highlight inactive items" do
      render_inline(described_class.new(sections: sections))

      projects_link = page.find_link("Projects")
      expect(projects_link[:class]).not_to include("bg-blue-50")
      expect(projects_link["aria-current"]).to be_nil
    end
  end

  describe "disabled items" do
    it "applies disabled styling" do
      sections_with_disabled = [
        {
          id: "main",
          title: "Main",
          items: [
            {label: "Coming Soon", href: "/soon", disabled: true}
          ]
        }
      ]
      render_inline(described_class.new(sections: sections_with_disabled))

      coming_soon_link = page.find_link("Coming Soon")
      expect(coming_soon_link[:class]).to include("cursor-not-allowed")
    end
  end

  describe "separators" do
    it "renders separators" do
      sections_with_separator = [
        {
          id: "main",
          items: [
            {label: "Dashboard", href: "/dashboard"},
            {type: :separator},
            {label: "Settings", href: "/settings"}
          ]
        }
      ]
      render_inline(described_class.new(sections: sections_with_separator))

      expect(page).to have_css("[role='separator']")
    end
  end

  describe "accessibility" do
    it "has proper aria-label on aside" do
      render_inline(described_class.new(sections: sections))

      aside = page.find("aside")
      expect(aside["aria-label"]).to eq("Sidebar navigation")
    end

    it "has aria-current on active items" do
      render_inline(described_class.new(sections: sections))

      dashboard_link = page.find_link("Dashboard")
      expect(dashboard_link["aria-current"]).to eq("page")
    end

    it "has aria-label on collapse button" do
      render_inline(described_class.new(sections: sections, collapsible: true))

      collapse_button = page.find("button[aria-label='Toggle sidebar']")
      expect(collapse_button).to be_present
    end
  end

  describe "stimulus integration" do
    it "has sidebar controller" do
      render_inline(described_class.new(sections: sections))

      expect(page).to have_css("[data-controller='sidebar']")
    end

    it "has collapsible value set" do
      render_inline(described_class.new(sections: sections, collapsible: true))

      controller_elem = page.find("[data-controller='sidebar']")
      expect(controller_elem["data-sidebar-collapsible-value"]).to eq("true")
    end

    it "has toggle action on collapse button" do
      render_inline(described_class.new(sections: sections, collapsible: true))

      collapse_button = page.find("[data-sidebar-target='collapseButton']")
      expect(collapse_button["data-action"]).to include("click->sidebar#toggle")
    end

    it "has toggleSection action on collapsible section headers" do
      render_inline(described_class.new(sections: sections))

      settings_header = page.find("button[data-section-id='settings']")
      expect(settings_header["data-action"]).to include("click->sidebar#toggleSection")
    end

    it "has proper targets" do
      render_inline(described_class.new(sections: sections))

      expect(page).to have_css("[data-sidebar-target='logo']")
      expect(page).to have_css("[data-sidebar-target='navigation']")
      expect(page).to have_css("[data-sidebar-target='footer']")
      expect(page).to have_css("[data-sidebar-target='sectionContent']", count: 2)
      expect(page).to have_css("[data-sidebar-target='navItem']", count: 4)
    end

    it "has section_id on section content" do
      render_inline(described_class.new(sections: sections))

      main_section = page.find("[data-sidebar-target='sectionContent'][data-section-id='main']")
      expect(main_section).to be_present
    end
  end

  describe "section titles" do
    it "renders section titles" do
      render_inline(described_class.new(sections: sections))

      expect(page).to have_css(".uppercase", text: "MAIN MENU")
      expect(page).to have_css(".uppercase", text: "SETTINGS")
    end

    it "has sectionTitle target on titles" do
      render_inline(described_class.new(sections: sections))

      expect(page).to have_css("[data-sidebar-target='sectionTitle']", count: 2)
    end
  end

  describe "item labels" do
    it "has itemLabel target on all navigation items" do
      render_inline(described_class.new(sections: sections))

      expect(page).to have_css("[data-sidebar-target='itemLabel']", count: 4)
    end
  end
end
