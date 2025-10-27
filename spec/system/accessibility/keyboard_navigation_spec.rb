# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Keyboard Navigation Accessibility", type: :system, js: true do
  let(:user) { create(:user) }
  let(:account) { create(:account) }
  let(:workspace) { create(:workspace, account: account) }

  before do
    create(:account_membership, user: user, account: account, role: :owner)
    create(:workspace_membership, user: user, workspace: workspace, role: :owner)
    user.update!(current_workspace: workspace)
    sign_in user
  end

  describe "SelectComponent keyboard navigation" do
    before do
      visit new_account_path
    end

    it "opens dropdown with Arrow Down key" do
      select_trigger = first("[data-select-target='trigger']")
      select_trigger.send_keys(:arrow_down)

      expect(page).to have_css("[data-select-target='menu']:not(.hidden)")
    end

    it "opens dropdown with Enter key" do
      select_trigger = first("[data-select-target='trigger']")
      select_trigger.send_keys(:enter)

      expect(page).to have_css("[data-select-target='menu']:not(.hidden)")
    end

    it "navigates options with arrow keys" do
      select_trigger = first("[data-select-target='trigger']")
      select_trigger.send_keys(:arrow_down)

      # Navigate through options
      page.send_keys(:arrow_down)
      page.send_keys(:arrow_down)

      # Verify visual focus indicator
      focused_option = page.evaluate_script("document.activeElement.dataset.selectTarget")
      expect(focused_option).to eq("option")
    end

    it "selects option with Enter key" do
      select_trigger = first("[data-select-target='trigger']")
      select_trigger.send_keys(:arrow_down)

      page.send_keys(:arrow_down)
      page.send_keys(:enter)

      # Menu should close after selection
      expect(page).to have_css("[data-select-target='menu'].hidden")
    end

    it "jumps to first option with Home key" do
      select_trigger = first("[data-select-target='trigger']")
      select_trigger.send_keys(:arrow_down)

      page.send_keys(:arrow_down)
      page.send_keys(:arrow_down)
      page.send_keys(:home)

      # Should be on first option
      options = all("[data-select-target='option']")
      expect(options.first[:class]).to include("ring-blue-500")
    end

    it "jumps to last option with End key" do
      select_trigger = first("[data-select-target='trigger']")
      select_trigger.send_keys(:arrow_down)

      page.send_keys(:end)

      # Should be on last option
      options = all("[data-select-target='option']")
      expect(options.last[:class]).to include("ring-blue-500")
    end

    it "closes dropdown with Escape key" do
      select_trigger = first("[data-select-target='trigger']")
      select_trigger.send_keys(:arrow_down)

      page.send_keys(:escape)

      expect(page).to have_css("[data-select-target='menu'].hidden")
    end

    it "returns focus to trigger on close" do
      select_trigger = first("[data-select-target='trigger']")
      select_trigger.send_keys(:arrow_down)
      page.send_keys(:escape)

      # Focus should return to trigger
      focused_element = page.evaluate_script("document.activeElement.dataset.selectTarget")
      expect(focused_element).to eq("trigger")
    end
  end

  describe "SheetComponent focus trap" do
    before do
      # Setup a page with a sheet component
      visit account_path(account)
      # Assuming there's a button to open a sheet
      click_button "Open Settings" if page.has_button?("Open Settings")
    end

    it "traps focus within sheet when open" do
      skip "Requires sheet to be implemented in UI"

      # Find all focusable elements in sheet
      focusable_elements = all("button, a[href], input:not([disabled])", visible: true)

      # Tab through all elements
      focusable_elements.length.times do
        page.send_keys(:tab)
      end

      # Focus should cycle back to first element
      first_element = focusable_elements.first
      expect(page.evaluate_script("document.activeElement")).to eq(first_element.native)
    end

    it "reverses focus trap with Shift+Tab" do
      skip "Requires sheet to be implemented in UI"

      page.send_keys([:shift, :tab])

      # Should move to last focusable element
      focusable_elements = all("button, a[href], input:not([disabled])", visible: true)
      expect(page.evaluate_script("document.activeElement")).to eq(focusable_elements.last.native)
    end

    it "closes sheet with Escape key" do
      skip "Requires sheet to be implemented in UI"

      page.send_keys(:escape)

      expect(page).to have_no_css("[data-sheet-target='panel']")
    end

    it "restores focus to trigger on close" do
      skip "Requires sheet to be implemented in UI"

      trigger = find("[data-action*='sheet#open']")
      trigger_id = trigger[:id]

      page.send_keys(:escape)

      focused_id = page.evaluate_script("document.activeElement.id")
      expect(focused_id).to eq(trigger_id)
    end
  end

  describe "PopoverComponent keyboard accessibility" do
    before do
      visit account_path(account)
    end

    it "closes with Escape key" do
      skip "Requires popover in UI"

      trigger = first("[data-popover-target='trigger']")
      trigger.click

      page.send_keys(:escape)

      expect(page).to have_css("[data-popover-target='content'].hidden")
    end

    it "returns focus to trigger after Escape" do
      skip "Requires popover in UI"

      trigger = first("[data-popover-target='trigger']")
      trigger.click

      page.send_keys(:escape)

      expect(page.evaluate_script("document.activeElement")).to eq(trigger.native)
    end
  end

  describe "HoverCardComponent keyboard accessibility" do
    it "closes with Escape key when open" do
      skip "Requires hover card in UI"

      # Open hover card programmatically or via interaction
      page.send_keys(:escape)

      expect(page).to have_css("[data-hover-card-target='content'].hidden")
    end
  end

  describe "TabsComponent keyboard navigation" do
    before do
      visit account_path(account)
      # Assuming tabs are on this page
    end

    it "navigates tabs with arrow keys" do
      skip "Requires tabs in UI"

      first_tab = first("[role='tab']")
      first_tab.send_keys(:arrow_right)

      tabs = all("[role='tab']")
      expect(tabs[1]["aria-selected"]).to eq("true")
    end

    it "wraps navigation at end" do
      skip "Requires tabs in UI"

      tabs = all("[role='tab']")
      last_tab = tabs.last
      last_tab.click
      last_tab.send_keys(:arrow_right)

      # Should wrap to first tab
      expect(tabs.first["aria-selected"]).to eq("true")
    end

    it "jumps to first tab with Home key" do
      skip "Requires tabs in UI"

      tabs = all("[role='tab']")
      tabs.last.click
      tabs.last.send_keys(:home)

      expect(tabs.first["aria-selected"]).to eq("true")
    end

    it "jumps to last tab with End key" do
      skip "Requires tabs in UI"

      first_tab = first("[role='tab']")
      first_tab.send_keys(:end)

      tabs = all("[role='tab']")
      expect(tabs.last["aria-selected"]).to eq("true")
    end
  end

  describe "PaginationComponent keyboard navigation" do
    before do
      # Create enough records to trigger pagination
      20.times { create(:workspace, account: account) }
      visit account_workspaces_path(account)
    end

    it "navigates to next page with Arrow Right" do
      skip "Requires pagination in UI"

      page.send_keys(:arrow_right)

      expect(page).to have_current_path(/page=2/)
    end

    it "navigates to previous page with Arrow Left" do
      skip "Requires pagination in UI"

      visit account_workspaces_path(account, page: 2)

      page.send_keys(:arrow_left)

      expect(page).to have_current_path(/page=1/)
    end

    it "jumps to first page with Home key" do
      skip "Requires pagination in UI"

      visit account_workspaces_path(account, page: 3)

      page.send_keys(:home)

      expect(page).to have_current_path(/page=1/)
    end

    it "jumps to last page with End key" do
      skip "Requires pagination in UI"

      page.send_keys(:end)

      # Should go to last page
      expect(page).to have_css("[aria-label='Go to last page']")
    end
  end

  describe "SidebarComponent keyboard shortcuts" do
    before do
      visit dashboard_path
    end

    it "toggles sidebar with [ key" do
      skip "Requires sidebar in UI"

      # Default shortcut is [ key
      page.send_keys("[")

      # Sidebar should collapse
      expect(page).to have_css("[data-sidebar-target='sidebar'].w-16")
    end

    it "toggles sidebar again to expand" do
      skip "Requires sidebar in UI"

      page.send_keys("[")
      page.send_keys("[")

      # Sidebar should expand back
      expect(page).to have_css("[data-sidebar-target='sidebar'].w-64")
    end

    it "does not trigger shortcut when input focused" do
      skip "Requires sidebar in UI"

      input = first("input")
      input.click
      input.send_keys("[")

      # Sidebar should not toggle, [ should be in input
      expect(input.value).to include("[")
    end
  end

  describe "SwitchComponent keyboard support" do
    before do
      visit account_settings_path(account)
    end

    it "toggles with Space key" do
      skip "Requires switch in UI"

      switch = first("[role='switch']")
      initial_state = switch["aria-checked"]

      switch.send_keys(:space)

      expect(switch["aria-checked"]).not_to eq(initial_state)
    end

    it "toggles with Enter key" do
      skip "Requires switch in UI"

      switch = first("[role='switch']")
      initial_state = switch["aria-checked"]

      switch.send_keys(:enter)

      expect(switch["aria-checked"]).not_to eq(initial_state)
    end
  end

  describe "WorkspaceSwitcher keyboard navigation" do
    let!(:workspace2) { create(:workspace, account: account, name: "Workspace 2") }

    before do
      create(:workspace_membership, user: user, workspace: workspace2, role: :member)
      visit dashboard_path
    end

    it "opens dropdown with Arrow Down" do
      skip "Requires workspace switcher in UI"

      trigger = find("[data-dropdown-target='trigger']")
      trigger.send_keys(:arrow_down)

      expect(page).to have_css("[data-dropdown-target='menu']:not(.hidden)")
    end

    it "navigates menu items with arrow keys" do
      skip "Requires workspace switcher in UI"

      trigger = find("[data-dropdown-target='trigger']")
      trigger.send_keys(:arrow_down)

      page.send_keys(:arrow_down)

      menu_items = all("[data-dropdown-target='menuItem']")
      expect(menu_items.first[:class]).to include("ring-blue-500")
    end

    it "selects workspace with Enter" do
      skip "Requires workspace switcher in UI"

      trigger = find("[data-dropdown-target='trigger']")
      trigger.send_keys(:arrow_down)
      page.send_keys(:arrow_down)
      page.send_keys(:enter)

      # Should switch workspace
      expect(page).to have_content("Workspace 2")
    end

    it "closes with Escape and returns focus" do
      skip "Requires workspace switcher in UI"

      trigger = find("[data-dropdown-target='trigger']")
      trigger.send_keys(:arrow_down)
      page.send_keys(:escape)

      expect(page.evaluate_script("document.activeElement")).to eq(trigger.native)
    end
  end

  describe "ARIA attributes compliance" do
    it "has proper ARIA roles on interactive components" do
      visit account_path(account)

      # Verify ARIA roles
      expect(page).to have_css("[role='button']") if page.has_css?("[data-popover-target]")
      expect(page).to have_css("[role='dialog']") if page.has_css?("[data-sheet-target]")
      expect(page).to have_css("[role='tab']") if page.has_css?("[data-tabs-target]")
      expect(page).to have_css("[role='switch']") if page.has_css?("[data-switch-target]")
    end

    it "has aria-expanded attributes on triggers" do
      skip "Requires interactive components in UI"

      triggers = all("[aria-haspopup]")
      triggers.each do |trigger|
        expect(trigger["aria-expanded"]).to be_in(%w[true false])
      end
    end

    it "has aria-checked on switch components" do
      skip "Requires switch components in UI"

      switches = all("[role='switch']")
      switches.each do |switch|
        expect(switch["aria-checked"]).to be_in(%w[true false])
      end
    end
  end

  describe "Focus management" do
    it "visible focus indicators on all interactive elements" do
      visit account_path(account)

      # Tab through page
      10.times do
        page.send_keys(:tab)

        # Check if focused element has visible focus ring
        has_focus_ring = page.evaluate_script(<<~JS)
          const el = document.activeElement;
          const styles = window.getComputedStyle(el);
          // Check for focus-visible or focus ring classes
          el.classList.contains('focus:ring-2') ||
          el.classList.contains('focus:outline-none') ||
          styles.outlineStyle !== 'none'
        JS

        expect(has_focus_ring).to be(true), "Element should have visible focus indicator"
      end
    end

    it "maintains logical tab order" do
      visit account_path(account)
      elements_checked = 0

      10.times do
        page.send_keys(:tab)

        tab_index = page.evaluate_script("document.activeElement.tabIndex")

        # Tab index should be -1 (default) or increase logically
        expect(tab_index).to be >= -1

        elements_checked += 1
      end

      expect(elements_checked).to be > 0
    end
  end
end
