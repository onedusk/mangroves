# Test Failures Report

Generated: 2025-12-24

## Summary

Total Failures: 249
Total Pending: 4

---

## Pending Tests (Expected, Not Blocking)

1. **AccountMembership** - spec/models/account_membership_spec.rb:37
   - Not yet implemented

2. **Account** - spec/models/account_spec.rb:30
   - Not yet implemented

3. **Team (tenant scoped)** - spec/support/shared_examples/tenant_scoped.rb:40
   - "raises an error when Current.account is missing"
   - Model has alternative account assignment

4. **User** - spec/models/user_spec.rb:50
   - Not yet implemented

---

## Component Failures

### AccordionComponent
- **XSS protection escapes HTML in content** - spec/components/accordion_component_spec.rb:71
  - Expected not to include "onerror=" but HTML was not properly escaped

### AvatarComponent (4 failures)
All failures due to `ArgumentError: unknown keyword: :alt`
- Renders image avatar - spec/components/avatar_component_spec.rb:8
- Includes proper accessibility attributes - spec/components/avatar_component_spec.rb:37
- XSS: escapes alt text - spec/components/avatar_component_spec.rb:46
- XSS: sanitizes src attribute - spec/components/avatar_component_spec.rb:52

**Root cause**: Component doesn't accept `:alt` parameter in initialize method

### BadgeComponent (3 failures)
- Renders with text - spec/components/badge_component_spec.rb:4
- XSS: escapes text content - spec/components/badge_component_spec.rb:82
- XSS: escapes variant attribute - spec/components/badge_component_spec.rb:88

**Root cause**: Component expects single argument but tests pass keyword arguments

### BreadcrumbComponent (2 failures)
- XSS: escapes item labels - spec/components/breadcrumb_component_spec.rb:64
- XSS: sanitizes href attributes - spec/components/breadcrumb_component_spec.rb:70

**Root cause**: Expected not to include "javascript:" but it was present

### ButtonComponent (6 failures)
- Renders primary variant - spec/components/button_component_spec.rb:4
- Renders secondary variant - spec/components/button_component_spec.rb:10
- Renders destructive variant - spec/components/button_component_spec.rb:16
- Renders ghost variant - spec/components/button_component_spec.rb:22
- XSS: escapes text content - spec/components/button_component_spec.rb:110
- XSS: escapes href attributes - spec/components/button_component_spec.rb:116

**Root cause**: Expected block but none given

### CardComponent (6 failures)
- Renders with header - spec/components/card_component_spec.rb:4
- Renders with footer - spec/components/card_component_spec.rb:10
- Renders with description - spec/components/card_component_spec.rb:16
- XSS: escapes header content - spec/components/card_component_spec.rb:76
- XSS: escapes description content - spec/components/card_component_spec.rb:82
- XSS: escapes footer content - spec/components/card_component_spec.rb:88

**Root cause**: Expected block but none given

### CheckboxComponent (6 failures)
All due to `ArgumentError: unknown keyword: :checked`
- Renders unchecked by default - spec/components/checkbox_component_spec.rb:4
- Renders checked state - spec/components/checkbox_component_spec.rb:10
- Renders disabled state - spec/components/checkbox_component_spec.rb:16
- Renders with label - spec/components/checkbox_component_spec.rb:22
- XSS: escapes label content - spec/components/checkbox_component_spec.rb:94
- XSS: sanitizes name attribute - spec/components/checkbox_component_spec.rb:100

### DialogComponent (15 failures)
All failures related to missing block or XSS issues
- Multiple render failures due to "expected block but none given"
- XSS failures for title, description, and trigger content not being escaped

### DropdownMenuComponent (6 failures)
- Missing block errors
- XSS issues with trigger and item content not being escaped

### InputComponent (4 failures)
- All due to `ArgumentError: unknown keyword: :type`
- Text input, email input, password input, disabled input tests failing

### LabelComponent (3 failures)
- Renders with text
- Renders with required indicator
- XSS: escapes text content

**Root cause**: Expected block but none given

### RadioGroupComponent (4 failures)
- All due to `ArgumentError: unknown keyword: :options`

### SelectComponent (4 failures)
- All due to `ArgumentError: unknown keyword: :options`

### SeparatorComponent (1 failure)
- Renders horizontal separator
**Root cause**: Expected block but none given

### SidebarComponent (8 failures)
- Various render tests failing with missing block
- XSS protection failures

### SkeletonComponent (3 failures)
- Circle variant, text variant, avatar variant
**Root cause**: Expected block but none given

### SwitchComponent (4 failures)
- All due to `ArgumentError: unknown keyword: :checked`

### TableComponent (6 failures)
- Rendering and XSS protection failures
- Expected block but none given

### TabsComponent (6 failures)
- Rendering and XSS protection failures
- Expected block but none given

### TextareaComponent (4 failures)
- All due to `ArgumentError: unknown keyword: :rows`

### ToastComponent (3 failures)
- Default toast, success toast, error toast
**Root cause**: Expected block but none given

### TooltipComponent (3 failures)
- Renders with content, positions, XSS protection
**Root cause**: Expected block but none given

### WorkspaceSwitcher (6 failures)
- Rendering and interaction failures
- Expected block but none given

---

## Request Spec Failures

### Accounts::Workspaces (6 failures)
All in spec/requests/accounts/workspaces_spec.rb
- POST /accounts/:account_id/workspaces - creates workspace (line 26)
- POST - returns created workspace data (line 39)
- POST - sets current_workspace_id (line 51)
- POST - validates required fields (line 63)
- PATCH - updates workspace (line 76)
- PATCH - validates required fields (line 92)

**Error**: Expected response to be successful but was 500

### Users::Workspaces (2 failures)
- PATCH /users/current_workspace - updates current workspace (line 19)
- PATCH - returns error for invalid workspace (line 34)

**Error**: Expected response to be successful but was 500

---

## System Test Failures (Accessibility)

All in spec/system/accessibility/ - approximately 130+ failures

### Common Issues:
1. **Capybara::ElementNotFound** - Unable to find elements on page
2. **Database cleanup issues** - Tests failing due to data not being properly set up
3. **Navigation failures** - Elements not visible or not found

### Affected Test Categories:
- **Focus management** (55 failures)
  - Focus indicators, focus trapping, tab order

- **Keyboard navigation** (50+ failures)
  - Arrow key navigation
  - Enter/Space key activation
  - Escape key handling
  - Keyboard shortcuts

- **Screen reader support** (20+ failures)
  - ARIA attributes
  - Live regions
  - Form labels
  - Heading hierarchy

- **Component-specific tests**:
  - AccordionComponent keyboard tests
  - ButtonComponent focus tests
  - DialogComponent keyboard tests
  - DropdownMenuComponent navigation
  - SelectComponent keyboard support
  - SidebarComponent shortcuts
  - SwitchComponent keyboard support
  - WorkspaceSwitcher navigation

---

## Common Error Patterns

### 1. ArgumentError: unknown keyword
Components not accepting keyword arguments that tests are passing:
- `:alt` (AvatarComponent)
- `:checked` (CheckboxComponent, SwitchComponent)
- `:type` (InputComponent)
- `:options` (RadioGroupComponent, SelectComponent)
- `:rows` (TextareaComponent)

### 2. LocalJumpError: no block given
Many components expecting blocks but tests not providing them:
- ButtonComponent
- CardComponent
- DialogComponent
- DropdownMenuComponent
- LabelComponent
- SeparatorComponent
- SkeletonComponent
- TableComponent
- TabsComponent
- ToastComponent
- TooltipComponent
- WorkspaceSwitcher

### 3. XSS Protection Failures
HTML/JavaScript not being properly escaped:
- AccordionComponent
- BreadcrumbComponent
- Various other components

### 4. System Test Infrastructure Issues
- Capybara can't find elements
- Database state not properly set up
- Navigation/routing issues

---

## Recommended Actions

1. **Fix Component Initializers**: Update component initialize methods to accept all keyword arguments used in tests
2. **Fix Block Handling**: Ensure components that use blocks are tested with proper block syntax
3. **Fix XSS Protection**: Implement proper HTML escaping in all components
4. **Fix System Test Setup**: Review system test helpers and database setup
5. **Fix Request Specs**: Debug 500 errors in workspace-related endpoints

---

## Test Command Used
```bash
bin/rake spec
```

## Warning Encountered
```
Status code :unprocessable_entity is deprecated and will be removed in a future version of Rack.
Please use :unprocessable_content instead.
```
