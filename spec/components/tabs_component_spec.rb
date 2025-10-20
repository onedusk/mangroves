# frozen_string_literal: true

require "rails_helper"

RSpec.describe TabsComponent, type: :component do
  let(:tabs) do
    [
      {id: "account", label: "Account", content: "Account settings content"},
      {id: "security", label: "Security", content: "Security settings content"},
      {id: "notifications", label: "Notifications", content: "Notifications content"}
    ]
  end

  describe "rendering" do
    it "renders tabs structure" do
      render_inline(described_class.new(tabs: tabs))

      expect(page).to have_selector("[data-controller='tabs']")
      expect(page).to have_selector("[role='tablist']")
      expect(page).to have_selector("[role='tab']", count: 3)
      expect(page).to have_selector("[role='tabpanel']", count: 3)
    end

    it "renders tab buttons" do
      render_inline(described_class.new(tabs: tabs))

      expect(page).to have_button("Account")
      expect(page).to have_button("Security")
      expect(page).to have_button("Notifications")
    end

    it "renders tab panels with content" do
      render_inline(described_class.new(tabs: tabs))

      expect(page).to have_text("Account settings content")
      expect(page).to have_text("Security settings content")
      expect(page).to have_text("Notifications content")
    end

    it "renders icons when provided" do
      tabs_with_icons = [
        {id: "home", label: "Home", icon: "🏠", content: "Home content"}
      ]
      render_inline(described_class.new(tabs: tabs_with_icons))

      expect(page).to have_text("🏠")
    end

    it "renders badges when provided" do
      tabs_with_badges = [
        {id: "inbox", label: "Inbox", badge: "5", content: "Inbox content"}
      ]
      render_inline(described_class.new(tabs: tabs_with_badges))

      expect(page).to have_selector(".rounded-full", text: "5")
    end
  end

  describe "default tab" do
    it "activates first tab by default" do
      render_inline(described_class.new(tabs: tabs))

      account_tab = page.find_button("Account")
      expect(account_tab["aria-selected"]).to eq("true")
      expect(account_tab["tabindex"]).to eq("0")
    end

    it "activates specified default tab" do
      render_inline(described_class.new(tabs: tabs, default_tab: "security"))

      security_tab = page.find_button("Security")
      expect(security_tab["aria-selected"]).to eq("true")
      expect(security_tab["tabindex"]).to eq("0")
    end

    it "sets inactive tabs to tabindex -1" do
      render_inline(described_class.new(tabs: tabs))

      security_tab = page.find_button("Security")
      notifications_tab = page.find_button("Notifications")

      expect(security_tab["tabindex"]).to eq("-1")
      expect(notifications_tab["tabindex"]).to eq("-1")
    end
  end

  describe "panel visibility" do
    it "shows default panel" do
      render_inline(described_class.new(tabs: tabs))

      account_panel = page.find("#panel-account")
      expect(account_panel[:class]).not_to include("hidden")
    end

    it "hides non-default panels" do
      render_inline(described_class.new(tabs: tabs))

      security_panel = page.find("#panel-security", visible: :all)
      notifications_panel = page.find("#panel-notifications", visible: :all)

      expect(security_panel[:class]).to include("hidden")
      expect(notifications_panel[:class]).to include("hidden")
    end
  end

  describe "orientation" do
    it "applies horizontal layout by default" do
      render_inline(described_class.new(tabs: tabs))

      tablist = page.find("[role='tablist']")
      expect(tablist[:class]).to include("border-b")
      expect(tablist[:class]).not_to include("flex-col")
    end

    it "applies vertical layout when specified" do
      render_inline(described_class.new(tabs: tabs, orientation: :vertical))

      tablist = page.find("[role='tablist']")
      expect(tablist[:class]).to include("flex-col", "border-r")
    end

    it "applies correct border style for horizontal tabs" do
      render_inline(described_class.new(tabs: tabs, orientation: :horizontal))

      account_tab = page.find_button("Account")
      expect(account_tab[:class]).to include("border-b-2")
    end

    it "applies correct border style for vertical tabs" do
      render_inline(described_class.new(tabs: tabs, orientation: :vertical))

      account_tab = page.find_button("Account")
      expect(account_tab[:class]).to include("border-r-2")
    end
  end

  describe "active state styling" do
    it "applies active styles to default tab" do
      render_inline(described_class.new(tabs: tabs))

      account_tab = page.find_button("Account")
      expect(account_tab[:class]).to include("border-blue-500", "text-blue-700")
    end

    it "applies inactive styles to non-default tabs" do
      render_inline(described_class.new(tabs: tabs))

      security_tab = page.find_button("Security")
      expect(security_tab[:class]).to include("border-transparent", "text-gray-600")
    end
  end

  describe "accessibility" do
    it "has proper role on tablist" do
      render_inline(described_class.new(tabs: tabs))

      tablist = page.find("[role='tablist']")
      expect(tablist["aria-label"]).to eq("Tabs")
      expect(tablist["aria-orientation"]).to eq("horizontal")
    end

    it "has vertical orientation aria attribute when vertical" do
      render_inline(described_class.new(tabs: tabs, orientation: :vertical))

      tablist = page.find("[role='tablist']")
      expect(tablist["aria-orientation"]).to eq("vertical")
    end

    it "has proper tab attributes" do
      render_inline(described_class.new(tabs: tabs))

      account_tab = page.find_button("Account")
      expect(account_tab["role"]).to eq("tab")
      expect(account_tab["id"]).to eq("tab-account")
      expect(account_tab["aria-controls"]).to eq("panel-account")
    end

    it "has proper panel attributes" do
      render_inline(described_class.new(tabs: tabs))

      account_panel = page.find("#panel-account")
      expect(account_panel["role"]).to eq("tabpanel")
      expect(account_panel["aria-labelledby"]).to eq("tab-account")
      expect(account_panel["tabindex"]).to eq("0")
    end
  end

  describe "stimulus integration" do
    it "has tabs controller" do
      render_inline(described_class.new(tabs: tabs))

      expect(page).to have_selector("[data-controller='tabs']")
    end

    it "has default value set" do
      render_inline(described_class.new(tabs: tabs, default_tab: "security"))

      controller_elem = page.find("[data-controller='tabs']")
      expect(controller_elem["data-tabs-default-value"]).to eq("security")
    end

    it "has orientation value set" do
      render_inline(described_class.new(tabs: tabs, orientation: :vertical))

      controller_elem = page.find("[data-controller='tabs']")
      expect(controller_elem["data-tabs-orientation-value"]).to eq("vertical")
    end

    it "has select action on tabs" do
      render_inline(described_class.new(tabs: tabs))

      account_tab = page.find_button("Account")
      expect(account_tab["data-action"]).to include("click->tabs#selectTab")
    end

    it "has keydown action on tablist" do
      render_inline(described_class.new(tabs: tabs))

      tablist = page.find("[role='tablist']")
      expect(tablist["data-action"]).to include("keydown->tabs#handleKeydown")
    end

    it "has tab targets" do
      render_inline(described_class.new(tabs: tabs))

      tabs_buttons = page.all("button[data-tabs-target='tab']")
      expect(tabs_buttons.count).to eq(3)
    end

    it "has panel targets" do
      render_inline(described_class.new(tabs: tabs))

      panels = page.all("[data-tabs-target='panel']", visible: :all)
      expect(panels.count).to eq(3)
    end

    it "has tab_id data attribute" do
      render_inline(described_class.new(tabs: tabs))

      account_tab = page.find_button("Account")
      expect(account_tab["data-tab-id"]).to eq("account")
    end

    it "has panel_id data attribute" do
      render_inline(described_class.new(tabs: tabs))

      account_panel = page.find("#panel-account")
      expect(account_panel["data-panel-id"]).to eq("account")
    end
  end

  describe "with proc content" do
    it "renders content from proc" do
      tabs_with_proc = [
        {
          id: "dynamic",
          label: "Dynamic",
          content: -> { div(class: "test-class") { "Dynamic content" } }
        }
      ]
      render_inline(described_class.new(tabs: tabs_with_proc))

      expect(page).to have_selector(".test-class", text: "Dynamic content")
    end
  end
end
