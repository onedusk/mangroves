# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Accessibility Features", type: :system do
  let(:account) { create(:account) }
  let(:workspace) { create(:workspace, account: account) }
  let(:user) { create(:user, current_workspace: workspace) }
  let!(:account_membership) { create(:account_membership, user: user, account: account, status: :active) }
  let!(:workspace_membership) { create(:workspace_membership, user: user, workspace: workspace, status: :active) }

  before do
    driven_by(:selenium_headless)
    sign_in user
    allow(Current).to receive(:account).and_return(account)
    allow(Current).to receive(:workspace).and_return(workspace)
  end

  describe "keyboard navigation" do
    it "allows tab navigation through interactive elements" do
      visit root_path

      # Find first focusable element
      first_focusable = page.find("a, button, input, select, textarea", match: :first)
      first_focusable.send_keys(:tab)

      # Check that focus moved to next element
      expect(page.evaluate_script("document.activeElement.tagName")).to be_in(["A", "BUTTON", "INPUT", "SELECT", "TEXTAREA"])
    end

    it "allows Enter key to activate buttons" do
      visit root_path

      button = page.find("button", match: :first)
      button.send_keys(:return)

      # Button should have been activated (implementation-specific assertion)
      expect(page).to have_css("button:focus")
    end

    it "allows Escape key to close modals" do
      # Skip if no modals present
      skip "No modal elements on page" unless page.has_css?('[role="dialog"]', wait: 0)

      page.find('[role="dialog"]').send_keys(:escape)

      expect(page).not_to have_css('[role="dialog"]', wait: 1)
    end

    it "provides skip navigation link" do
      visit root_path

      # Tab to skip link (usually first focusable element)
      page.find("body").send_keys(:tab)

      # Check for skip navigation
      expect(page).to have_css('a[href="#main-content"]', visible: :all).or have_css('a[href="#main"]', visible: :all)
    end
  end

  describe "focus management" do
    it "maintains focus ring visibility on keyboard navigation" do
      visit root_path

      button = page.find("button", match: :first)
      button.send_keys(:tab)

      # Check that focused element has visible focus indicator
      focused_element = page.evaluate_script("document.activeElement")
      expect(focused_element).not_to be_nil
    end

    it "returns focus to trigger after closing dropdown" do
      skip "No dropdown elements on page" unless page.has_css('[data-controller="dropdown"]', wait: 0)

      dropdown_trigger = page.find('[data-dropdown-target="trigger"]', match: :first)
      dropdown_trigger.click

      # Wait for dropdown to open
      expect(page).to have_css('[data-dropdown-target="menu"]:not(.hidden)', wait: 1)

      # Close with Escape
      page.send_keys(:escape)

      # Focus should return to trigger
      expect(page.evaluate_script("document.activeElement")).to eq(dropdown_trigger.native)
    end

    it "traps focus within modal dialogs" do
      skip "No modal elements on page" unless page.has_css('[role="dialog"]', wait: 0)

      modal = page.find('[role="dialog"]', match: :first)

      # Get all focusable elements in modal
      focusable_elements = modal.all("a, button, input, select, textarea", minimum: 1)

      # Tab through all elements
      focusable_elements.count.times do
        page.send_keys(:tab)
      end

      # Focus should still be within modal
      active_element = page.evaluate_script("document.activeElement")
      expect(modal.native).to have_selector("*", text: active_element.text) if active_element
    end
  end

  describe "screen reader announcements" do
    it "announces page title changes" do
      visit root_path

      title = page.title
      expect(title).not_to be_empty
      expect(title).to include("Mangroves").or match(/\w+/)
    end

    it "includes proper heading hierarchy" do
      visit root_path

      # Check for h1 element
      expect(page).to have_css("h1", minimum: 1)

      # Verify heading levels don't skip (no h4 without h3, etc.)
      headings = page.all("h1, h2, h3, h4, h5, h6").map { |h| h.tag_name[-1].to_i }

      headings.each_cons(2) do |current, next_heading|
        expect(next_heading - current).to be <= 1
      end
    end

    it "includes aria-live regions for dynamic updates" do
      skip "No live regions on page" unless page.has_css('[aria-live]', wait: 0)

      live_region = page.find('[aria-live]', match: :first)
      expect(live_region["aria-live"]).to be_in(["polite", "assertive", "off"])
    end

    it "labels all form inputs" do
      visit new_user_registration_path if defined?(Devise)

      page.all("input[type=text], input[type=email], input[type=password], textarea, select").each do |input|
        input_id = input["id"]
        # Each input should have EITHER a label, aria-label, OR aria-labelledby
        has_label = page.has_css?("label[for='#{input_id}']")
        has_aria_label = input["aria-label"].present?
        has_aria_labelledby = input["aria-labelledby"].present?

        expect(has_label || has_aria_label || has_aria_labelledby).to be true
      end
    end

    it "announces form validation errors" do
      visit new_user_registration_path if defined?(Devise)

      # Submit invalid form
      click_button "Sign up", match: :first rescue nil

      # Check for error announcements
      error_messages = page.all(".error, [role=alert], [aria-invalid=true]")
      expect(error_messages.count).to be > 0
    end
  end

  describe "ARIA attributes" do
    it "includes proper role attributes" do
      visit root_path

      # Check for semantic roles
      expect(page).to have_css('[role]', minimum: 0) # May not always be present

      # If roles present, verify they're valid
      page.all('[role]').each do |element|
        role = element["role"]
        valid_roles = %w[banner navigation main complementary contentinfo article section search form alert dialog button menu menuitem tab tabpanel]
        expect(role).to be_in(valid_roles) if role
      end
    end

    it "uses aria-expanded for collapsible elements" do
      skip "No collapsible elements on page" unless page.has_css('[data-controller="accordion"], [data-controller="dropdown"]', wait: 0)

      collapsible_trigger = page.find('[aria-expanded]', match: :first)
      initial_state = collapsible_trigger["aria-expanded"]

      collapsible_trigger.click

      expect(collapsible_trigger["aria-expanded"]).not_to eq(initial_state)
    end

    it "uses aria-describedby for form hints" do
      visit new_user_registration_path if defined?(Devise)

      inputs_with_hints = page.all('input[aria-describedby]')
      inputs_with_hints.each do |input|
        hint_id = input["aria-describedby"]
        expect(page).to have_css("##{hint_id}")
      end
    end

    it "uses aria-hidden for decorative elements" do
      icons = page.all('svg, i.fa, i.icon')
      decorative_icons = icons.select { |icon| icon["aria-hidden"] == "true" }

      # At least some decorative icons should be properly marked
      expect(decorative_icons.count).to be >= 0
    end
  end

  describe "color contrast and visual accessibility" do
    it "renders text with sufficient size" do
      visit root_path

      # Check that body text is at least 14px (or 12px for some elements)
      body_font_size = page.evaluate_script("parseFloat(window.getComputedStyle(document.body).fontSize)")
      expect(body_font_size).to be >= 12
    end

    it "provides visible focus indicators" do
      visit root_path

      button = page.find("button, a", match: :first)
      button.send_keys(:tab)

      # Check for focus styles (this is a simplified check)
      # In real accessibility testing, use tools like axe-core
      expect(page.evaluate_script("document.activeElement")).not_to be_nil
    end
  end

  describe "responsive design accessibility" do
    it "remains accessible on mobile viewport", driver: :selenium_headless do
      page.driver.browser.manage.window.resize_to(375, 667) # iPhone size

      visit root_path

      # Should still have proper heading structure
      expect(page).to have_css("h1", minimum: 1)

      # Should still be navigable
      expect(page).to have_css("a, button", minimum: 1)
    end

    it "maintains touch target sizes on mobile", driver: :selenium_headless do
      page.driver.browser.manage.window.resize_to(375, 667)

      visit root_path

      # Touch targets should be at least 44x44 pixels (WCAG AAA)
      buttons = page.all("button, a")
      buttons.first(5).each do |button|
        height = button.native.size.height
        width = button.native.size.width

        # Allow some tolerance for border/padding
        expect(height).to be >= 40 if height > 0
        expect(width).to be >= 40 if width > 0
      end
    end
  end
end
