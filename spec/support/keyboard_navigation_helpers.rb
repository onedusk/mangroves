# frozen_string_literal: true

# Helper methods for testing keyboard navigation accessibility
module KeyboardNavigationHelpers
  # Simulates tabbing through elements and returns array of focused elements
  def tab_through_page(count: 10)
    focused_elements = []

    count.times do
      page.send_keys(:tab)
      focused_elements << page.evaluate_script("document.activeElement")
    end

    focused_elements
  end

  # Checks if element has visible focus indicator
  def has_focus_indicator?(element = nil)
    element_selector = element || "document.activeElement"

    page.evaluate_script(<<~JS)
      (function() {
        const el = #{element_selector};
        const styles = window.getComputedStyle(el);

        // Check for common focus indicator patterns
        const hasFocusRing = el.classList.contains('focus:ring-2') ||
                            el.classList.contains('focus-visible:ring-2') ||
                            el.classList.contains('ring-2');

        const hasOutline = styles.outlineStyle !== 'none' ||
                          styles.outlineWidth !== '0px';

        const hasBorder = el.classList.contains('focus:border-blue-500') ||
                         el.classList.contains('focus-visible:border-blue-500');

        return hasFocusRing || hasOutline || hasBorder;
      })()
    JS
  end

  # Verifies ARIA attributes are properly set
  def verify_aria_attributes(selector)
    element = find(selector)

    expectations = []

    # Check for required ARIA attributes based on role
    role = element["role"]

    case role
    when "button"
      expectations << { attribute: "aria-pressed", required: false }
      expectations << { attribute: "aria-expanded", required: false }
    when "tab"
      expectations << { attribute: "aria-selected", required: true, values: %w[true false] }
      expectations << { attribute: "aria-controls", required: true }
    when "switch"
      expectations << { attribute: "aria-checked", required: true, values: %w[true false] }
    when "dialog"
      expectations << { attribute: "aria-modal", required: false, values: %w[true false] }
      expectations << { attribute: "aria-labelledby", required: true }
    when "listbox"
      expectations << { attribute: "aria-multiselectable", required: false }
    when "option"
      expectations << { attribute: "aria-selected", required: false, values: %w[true false] }
    end

    expectations.each do |expectation|
      if expectation[:required]
        expect(element[expectation[:attribute]]).not_to be_nil,
          "#{role} must have #{expectation[:attribute]}"

        if expectation[:values]
          expect(element[expectation[:attribute]]).to be_in(expectation[:values]),
            "#{expectation[:attribute]} must be one of #{expectation[:values]}"
        end
      end
    end
  end

  # Tests keyboard navigation for dropdown/menu patterns
  def test_dropdown_keyboard_navigation(trigger_selector)
    trigger = find(trigger_selector)

    # Open with keyboard
    trigger.send_keys(:arrow_down)
    expect(page).to have_css("[data-dropdown-target='menu']:not(.hidden)",
                              wait: 1)

    # Navigate with arrows
    page.send_keys(:arrow_down)
    page.send_keys(:arrow_up)

    # Close with Escape
    page.send_keys(:escape)
    expect(page).to have_css("[data-dropdown-target='menu'].hidden",
                              wait: 1)

    # Verify focus returned to trigger
    expect(page.evaluate_script("document.activeElement")).to eq(trigger.native)
  end

  # Tests focus trap in modal/dialog patterns
  def test_focus_trap(container_selector)
    container = find(container_selector)

    # Get all focusable elements
    focusable = all("#{container_selector} button:not([disabled]), #{container_selector} a[href], " \
                   "#{container_selector} input:not([disabled]), #{container_selector} select:not([disabled])",
                   visible: true)

    return if focusable.empty?

    # Tab through all elements
    focusable.length.times do
      page.send_keys(:tab)
    end

    # Should cycle back to first element
    expect(page.evaluate_script("document.activeElement")).to eq(focusable.first.native)

    # Test reverse with Shift+Tab
    page.send_keys([:shift, :tab])
    expect(page.evaluate_script("document.activeElement")).to eq(focusable.last.native)
  end

  # Verifies keyboard shortcut works and doesn't trigger in inputs
  def test_keyboard_shortcut(key, expected_action:, input_safe: true)
    # Test shortcut works
    page.send_keys(key)
    yield if block_given? # Execute test for expected action

    if input_safe
      # Verify shortcut doesn't work when input focused
      input = find("input", match: :first)
      input.click
      input.send_keys(key)

      # Key should be in input value
      expect(input.value).to include(key)
    end
  end

  # Checks if element is keyboard accessible
  def keyboard_accessible?(selector)
    element = find(selector)

    # Must have tab index or be naturally focusable
    tab_index = element["tabindex"]
    tag_name = element.tag_name.downcase

    naturally_focusable = %w[a button input select textarea].include?(tag_name)

    # Either naturally focusable or has tabindex >= 0
    naturally_focusable || (tab_index && tab_index.to_i >= 0)
  end

  # Verifies all interactive elements are keyboard accessible
  def verify_keyboard_accessibility
    interactive_selectors = [
      "button",
      "a[href]",
      "[role='button']",
      "[role='tab']",
      "[role='switch']",
      "[role='menuitem']",
      "[data-action*='click']" # Stimulus click actions
    ]

    interactive_selectors.each do |selector|
      all(selector, visible: true).each do |element|
        expect(keyboard_accessible?(element[:id] || selector)).to be(true),
          "#{selector} must be keyboard accessible"
      end
    end
  end
end

RSpec.configure do |config|
  config.include KeyboardNavigationHelpers, type: :system
end
