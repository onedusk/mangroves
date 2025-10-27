# ARIA Usage Guide for Components

Quick reference for using components with proper ARIA semantics.

## Form Components

### InputComponent

```ruby
# Basic usage with label
InputComponent.new(
  name: "email",
  label: "Email Address",
  type: :email,
  required: true
)
# Renders: <input aria-required="true" aria-label="Email Address" />

# With hint text
InputComponent.new(
  name: "password",
  label: "Password",
  hint: "Must be at least 8 characters",
  required: true
)
# Renders: <input aria-describedby="password_hint" aria-required="true" />

# With validation error
InputComponent.new(
  name: "username",
  label: "Username",
  error_message: "Username is already taken",
  validation_state: :error
)
# Renders: <input aria-invalid="true" aria-describedby="username_error" />

# Disabled state
InputComponent.new(
  name: "readonly",
  label: "Read Only",
  disabled: true
)
# Renders: <input aria-disabled="true" />
```

### TextareaComponent

```ruby
TextareaComponent.new(
  name: "description",
  label: "Description",
  hint: "Provide details about the issue",
  max_length: 500,
  show_count: true,
  required: true
)
# Same ARIA patterns as InputComponent
```

### SelectComponent

```ruby
# Native select
SelectComponent.new(
  name: "country",
  label: "Country",
  options: [{value: "us", label: "United States"}],
  hint: "Select your country",
  required: true
)

# Custom select (searchable/multiple)
SelectComponent.new(
  name: "tags",
  label: "Tags",
  options: ["Ruby", "Rails", "JavaScript"],
  searchable: true,
  multiple: true
)
# Renders: <button aria-haspopup="listbox" aria-expanded="false" aria-controls="..." />
#          <div role="listbox" aria-multiselectable="true" />
```

## Interactive Components

### DropdownMenuComponent

```ruby
DropdownMenuComponent.new(
  trigger_text: "Actions",
  items: [
    {label: "Edit", href: "#edit"},
    {label: "Delete", href: "#delete", destructive: true}
  ]
)
# Renders: <button aria-haspopup="menu" aria-expanded="false" aria-controls="dropdown_menu_..." />
#          <div id="dropdown_menu_..." role="menu" aria-orientation="vertical" />
```

### PopoverComponent

```ruby
PopoverComponent.new(
  trigger_content: "Help"
) do
  "Additional information about this feature"
end
# Renders: <div role="button" aria-haspopup="dialog" aria-expanded="false" aria-controls="popover_..." />
#          <div id="popover_..." role="dialog" />
```

## Modal Components

### DialogComponent

```ruby
DialogComponent.new(
  title: "Confirm Action"
) do
  "Are you sure you want to proceed?"
end
# Renders: <div role="dialog" aria-modal="true" aria-labelledby="dialog_title_..." />
#          <h3 id="dialog_title_...">Confirm Action</h3>
```

### SheetComponent

```ruby
SheetComponent.new(
  title: "Settings",
  side: "right"
) do
  "Settings content here"
end
# Renders: <div role="dialog" aria-modal="true" aria-labelledby="sheet_title_..." />
```

### AlertDialogComponent

```ruby
AlertDialogComponent.new(
  title: "Delete Item",
  content: "This action cannot be undone",
  cancel_text: "Cancel",
  continue_text: "Delete"
)
# Renders: <div role="alertdialog" aria-modal="true" aria-labelledby="..." aria-describedby="..." />
```

## Notification Components

### ToastComponent

```ruby
ToastComponent.new(
  message: "Settings saved successfully",
  variant: :success,
  duration: 3000,
  dismissible: true
)
# Renders: <div role="alert" aria-live="polite" aria-atomic="true" />
```

### SonnerComponent

```ruby
SonnerComponent.new(
  message: "File uploaded",
  variant: :success,
  action_label: "View",
  action_url: "/files/123"
)
# Renders: <div role="alert" aria-live="polite" aria-atomic="true" />
```

### ProgressComponent

```ruby
# Determinate progress
ProgressComponent.new(
  value: 60,
  max: 100,
  label: "Upload Progress",
  variant: :info
)
# Renders: <div role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100"
#               aria-valuetext="60%" aria-live="polite" aria-atomic="false" />

# Indeterminate progress
ProgressComponent.new(
  indeterminate: true,
  label: "Loading..."
)
# Renders: <div role="progressbar" aria-live="polite" aria-label="Loading..." />
```

## Navigation Components

### NavigationMenuComponent

```ruby
NavigationMenuComponent.new(
  items: [
    {label: "Home", href: "/", match_exact: true},
    {label: "About", href: "/about"},
    {label: "Contact", href: "/contact"}
  ],
  current_path: "/"
)
# Renders: <nav aria-label="Main navigation">
#            <a href="/" aria-current="page">Home</a>
#          </nav>
```

### TabsComponent

```ruby
TabsComponent.new(
  tabs: [
    {id: "overview", label: "Overview", content: "Overview content"},
    {id: "details", label: "Details", content: "Details content"}
  ],
  default_tab: "overview"
)
# Renders: <div role="tablist" aria-label="Tabs" aria-orientation="horizontal">
#            <button role="tab" aria-selected="true" aria-controls="panel-overview" />
#          </div>
#          <div role="tabpanel" id="panel-overview" aria-labelledby="tab-overview" />
```

## Best Practices

### When to Use ARIA

1. **Use ARIA when native HTML is insufficient**
   - Native HTML elements have implicit semantics
   - Only add ARIA when you need custom widgets

2. **Follow the First Rule of ARIA**
   - If you can use a native element, use it
   - Don't change native semantics unless necessary

3. **Keep ARIA attributes synchronized**
   - Update `aria-expanded` when opening/closing
   - Update `aria-selected` when changing tabs
   - Update `aria-valuenow` when progress changes

### Common Patterns

#### Error State
```ruby
validation_state: :error,
error_message: "Error message"
# Results in: aria-invalid="true" aria-describedby="id_error"
```

#### Required Fields
```ruby
required: true
# Results in: aria-required="true"
```

#### Disabled Elements
```ruby
disabled: true
# Results in: aria-disabled="true"
```

#### Hints and Descriptions
```ruby
hint: "Helper text"
# Results in: aria-describedby="id_hint"
```

## Testing ARIA

### Manual Testing with Screen Readers

- **macOS**: VoiceOver (Cmd+F5)
- **Windows**: NVDA (free) or JAWS (commercial)
- **Chrome**: ChromeVox extension

### Automated Testing

```bash
# Run accessibility tests
bundle exec rspec spec/system/accessibility/

# Check specific component
bundle exec rspec spec/system/accessibility/component_aria_spec.rb -e "InputComponent"
```

### Browser DevTools

1. Chrome DevTools > Elements > Accessibility pane
2. Firefox DevTools > Accessibility panel
3. Check computed ARIA properties

## Resources

- [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
- [MDN ARIA Reference](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA)
- [Accessible Name Computation](https://www.w3.org/TR/accname-1.2/)
- [ARIA in HTML](https://www.w3.org/TR/html-aria/)
