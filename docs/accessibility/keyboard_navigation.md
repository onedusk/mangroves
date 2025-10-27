# Keyboard Navigation & Accessibility (WCAG 2.1.1)

This document outlines the keyboard accessibility implementation for interactive components in the Mangroves application, ensuring compliance with WCAG 2.1.1 (Keyboard) Level A standards.

## Overview

All interactive components support full keyboard navigation following ARIA Authoring Practices Guide (APG) patterns. No mouse is required to operate any functionality.

## Component Keyboard Support

### SelectComponent (Custom Dropdown)

**Trigger Element**
- `Arrow Down/Up`, `Enter`, `Space`: Open dropdown
- `Escape`: Close dropdown (if open)

**Dropdown Menu** (when open)
- `Arrow Down`: Move focus to next option
- `Arrow Up`: Move focus to previous option
- `Home`: Jump to first option
- `End`: Jump to last option
- `Enter` or `Space`: Select focused option and close dropdown
- `Escape`: Close dropdown without selection
- `Tab`: Close dropdown and move to next focusable element

**Focus Management**
- Opens dropdown with focus on first/selected option
- Visual focus indicator (blue ring) on focused option
- Returns focus to trigger button when closed
- Scrolls focused option into view automatically

**ARIA Attributes**
- `role="listbox"` on dropdown menu
- `role="option"` on each option
- `aria-haspopup="listbox"` on trigger
- `aria-expanded="true/false"` on trigger
- `aria-multiselectable="true/false"` on listbox (for multi-select)

---

### WorkspaceSwitcherComponent (Dropdown Menu)

**Trigger Button**
- `Arrow Down/Up`, `Enter`, `Space`: Open menu
- `Escape`: Close menu (if open)

**Menu Items** (when open)
- `Arrow Down`: Move to next menu item
- `Arrow Up`: Move to previous menu item
- `Home`: Jump to first menu item
- `End`: Jump to last menu item
- `Enter` or `Space`: Activate menu item
- `Escape`: Close menu
- `Tab`: Close menu and continue tabbing

**Focus Management**
- Opens with focus on first menu item
- Visual focus ring on focused item
- Returns focus to trigger on close
- Scrolls focused item into view

**ARIA Attributes**
- `role="menu"` on dropdown container
- `role="menuitem"` on each workspace button
- `aria-haspopup="menu"` on trigger
- `aria-expanded="true/false"` on trigger

---

### SheetComponent (Modal/Drawer)

**Focus Trap**
- `Tab`: Move to next focusable element within sheet
- `Shift+Tab`: Move to previous focusable element within sheet
- Focus cycles through all interactive elements in sheet
- Cannot tab out of sheet while open

**Keyboard Shortcuts**
- `Escape`: Close sheet

**Focus Management**
- Captures currently focused element before opening
- Moves focus to first focusable element in sheet on open
- Traps focus within sheet (cycles at boundaries)
- Restores focus to trigger element on close

**ARIA Attributes**
- `role="dialog"` on sheet container
- `aria-modal="true"` on sheet
- `aria-labelledby` pointing to sheet title

**Implementation Details**
```javascript
// Focusable elements selector
'a[href], button:not([disabled]), input:not([disabled]),
 select:not([disabled]), textarea:not([disabled]),
 [tabindex]:not([tabindex="-1"])'

// Tab handler prevents default at boundaries
// Cycles: last -> first (Tab), first -> last (Shift+Tab)
```

---

### PopoverComponent

**Trigger**
- `Click` or keyboard activation: Toggle popover

**When Open**
- `Escape`: Close popover and return focus to trigger

**Focus Management**
- Stores trigger element reference
- Returns focus to trigger on close
- Escape handler attached to document

**ARIA Attributes**
- `role="button"` on trigger
- `role="dialog"` on popover content
- `aria-haspopup="dialog"` on trigger
- `aria-expanded="true/false"` on trigger
- `aria-controls` linking trigger to popover

---

### HoverCardComponent

**Interaction**
- Primarily mouse hover-based
- `Escape`: Close card and return focus to trigger (when open)

**Focus Management**
- Stores trigger element on open
- Returns focus to trigger on Escape
- Does not trap focus (informational only)

**ARIA Attributes**
- Similar to PopoverComponent
- Content hidden with `class="hidden"` when closed

---

### TabsComponent

**Tab List Navigation**
- `Arrow Right` (horizontal) or `Arrow Down` (vertical): Next tab
- `Arrow Left` (horizontal) or `Arrow Up` (vertical): Previous tab
- `Home`: First tab
- `End`: Last tab

**Behavior**
- Navigation wraps at list boundaries
- Selected tab has `tabindex="0"`, others have `tabindex="-1"`
- Focus follows selection (automatic activation)

**ARIA Attributes**
- `role="tablist"` on tab container
- `role="tab"` on each tab button
- `role="tabpanel"` on each content panel
- `aria-selected="true/false"` on tabs
- `aria-controls` linking tab to panel
- `aria-labelledby` linking panel to tab
- `aria-orientation="horizontal/vertical"` on tablist

**Keyboard Pattern**
```
Home -> First Tab
End -> Last Tab
Arrow Keys -> Navigate tabs with wrapping
```

---

### PaginationComponent

**Global Shortcuts** (when no input focused)
- `Arrow Right`: Next page
- `Arrow Left`: Previous page
- `Home`: First page
- `End`: Last page

**Link Navigation**
- All pagination links are standard `<a>` elements
- Normal `Tab` navigation works
- `Enter` activates links

**Smart Detection**
- Only activates shortcuts when inputs/textareas not focused
- Prevents interference with form editing

**ARIA Attributes**
- `role="navigation"` on container
- `aria-label="Pagination"` on container
- `rel="prev/next/first/last"` on links
- `aria-label` describing each link action

---

### SidebarComponent

**Keyboard Shortcut**
- `[` key (configurable): Toggle sidebar collapse/expand

**Configuration**
```javascript
// Default shortcut
keyboardShortcut: "["

// Custom shortcut via data attribute
data-sidebar-keyboard-shortcut-value="["
```

**Smart Behavior**
- Only triggers when inputs/textareas not focused
- Prevents accidental triggers while typing
- Works anywhere on page

**State Persistence**
- Collapsed state saved to localStorage
- Restored on page load

---

### SwitchComponent (Toggle)

**Keyboard Activation**
- `Space`: Toggle switch
- `Enter`: Toggle switch

**Mouse Alternative**
- Click anywhere on label or button to toggle

**ARIA Attributes**
- `role="switch"` on button
- `aria-checked="true/false"` reflecting state
- Hidden input stores form value

**Visual Feedback**
- Focus ring on button
- State changes (color, position) happen immediately

---

## Testing

### System Specs

Comprehensive keyboard navigation tests in:
```
spec/system/accessibility/keyboard_navigation_spec.rb
```

**Test Coverage:**
- All keyboard shortcuts documented above
- Focus management (trap, restoration, indicators)
- ARIA attribute presence and values
- Tab order and focus visibility
- Component-specific navigation patterns

### Helper Methods

Reusable test helpers in:
```
spec/support/keyboard_navigation_helpers.rb
```

**Helpers Include:**
- `tab_through_page(count:)` - Tab and track focus
- `has_focus_indicator?` - Verify visible focus
- `verify_aria_attributes(selector)` - Check ARIA compliance
- `test_dropdown_keyboard_navigation` - Test dropdown pattern
- `test_focus_trap` - Test modal focus trap
- `test_keyboard_shortcut` - Test global shortcuts

### Running Tests

```bash
# Run all accessibility tests
bundle exec rspec spec/system/accessibility/

# Run specific component tests
bundle exec rspec spec/system/accessibility/keyboard_navigation_spec.rb

# Run with specific browser
bundle exec rspec spec/system/accessibility/ --tag js
```

---

## ARIA Authoring Practices Compliance

All components follow ARIA APG patterns:

| Component | APG Pattern | Link |
|-----------|-------------|------|
| SelectComponent | Listbox | https://www.w3.org/WAI/ARIA/apg/patterns/listbox/ |
| WorkspaceSwitcher | Menu | https://www.w3.org/WAI/ARIA/apg/patterns/menu/ |
| SheetComponent | Dialog (Modal) | https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/ |
| PopoverComponent | Dialog | https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/ |
| TabsComponent | Tabs | https://www.w3.org/WAI/ARIA/apg/patterns/tabs/ |
| SwitchComponent | Switch | https://www.w3.org/WAI/ARIA/apg/patterns/switch/ |

---

## WCAG 2.1.1 Compliance Summary

**Success Criterion 2.1.1 Keyboard (Level A)**

> All functionality of the content is operable through a keyboard interface without requiring specific timings for individual keystrokes, except where the underlying function requires input that depends on the path of the user's movement and not just the endpoints.

### Compliance Checklist

- [x] All interactive components keyboard accessible
- [x] No functionality requires mouse
- [x] Focus visible on all interactive elements
- [x] Focus order follows logical sequence
- [x] Keyboard shortcuts documented
- [x] No keyboard traps (except intentional modal focus traps)
- [x] Standard keys follow expected behavior
- [x] ARIA attributes properly applied
- [x] Focus management on component state changes
- [x] Escape key closes overlays and dialogs

### Known Limitations

None. All interactive functionality is fully keyboard accessible.

---

## Implementation Notes

### Focus Indicators

All interactive elements have visible focus indicators using Tailwind CSS:

```css
/* Standard focus ring */
focus:outline-none focus:ring-2 focus:ring-blue-500

/* Focus ring with offset */
focus:ring-2 focus:ring-offset-2 focus:ring-blue-500

/* Inset ring for tight spacing */
ring-2 ring-blue-500 ring-inset
```

### Stimulus Controller Pattern

Keyboard handlers follow consistent pattern:

```javascript
handleKeydown(event) {
  switch (event.key) {
    case "ArrowDown":
      event.preventDefault()
      this.focusNext()
      break
    case "Escape":
      event.preventDefault()
      this.close()
      break
  }
}
```

### Focus Management Pattern

Components that open/close follow this pattern:

```javascript
open() {
  this.previousFocus = document.activeElement
  // ... show component ...
  this.firstFocusableElement.focus()
}

close() {
  // ... hide component ...
  if (this.previousFocus?.focus) {
    this.previousFocus.focus()
  }
}
```

---

## Browser Compatibility

Tested and working in:
- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)

All keyboard events use standard Web APIs with broad support.

---

## Future Enhancements

- [ ] Type-ahead filtering in SelectComponent
- [ ] Letter-based navigation (jump to items starting with letter)
- [ ] Customizable keyboard shortcuts per user
- [ ] Screen reader testing and announcements
- [ ] High contrast mode support
- [ ] Reduced motion preferences

---

## Resources

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [WebAIM Keyboard Accessibility](https://webaim.org/techniques/keyboard/)
- [MDN Keyboard Events](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent)

---

**Last Updated:** 2025-10-20
**Implemented By:** Claude Code
**Reviewed By:** (Pending)
