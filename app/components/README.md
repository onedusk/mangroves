# Phlex Component Library

This directory contains 49 reusable Phlex components for building multi-tenant Rails applications. All components are built with Tailwind CSS and support responsive design, accessibility, and tenant-aware theming.

## Table of Contents

- [Overview](#overview)
- [Multi-Tenant Patterns](#multi-tenant-patterns)
- [Component Categories](#component-categories)
- [Usage Examples](#usage-examples)
- [Testing Components](#testing-components)
- [Styling Conventions](#styling-conventions)

## Overview

Phlex components are Ruby-based view components that render HTML using a clean DSL. Each component:

- Accepts explicit props in `initialize`
- Renders via the `template` method
- Uses Tailwind CSS for styling
- Includes responsive design patterns
- Supports Stimulus controllers for interactivity
- Can access tenant context via `Current.account`

## Multi-Tenant Patterns

### Accessing Tenant Context

Components can access the current tenant through the `Current` thread-local context:

```ruby
class BrandedHeaderComponent < Phlex::HTML
  def initialize(account: nil)
    @account = account || Current.account
  end

  def template
    div(class: "header") do
      if @account
        h1 { @account.name }
        img(src: @account.logo_url) if @account.logo_url
      end
    end
  end
end
```

### Tenant-Scoped Data

When passing ActiveRecord objects to components, ensure they're already scoped to the current tenant:

```ruby
# In controller
@projects = Current.account.projects # Already tenant-scoped

# In view
render ProjectListComponent.new(projects: @projects)
```

### Tenant Branding

Components support tenant-specific branding through account settings:

```ruby
class FooterComponent < Phlex::HTML
  def initialize(account: nil)
    @account = account || Current.account
  end

  private

  def brand_color
    @account&.settings&.dig("brand_color") || "#3B82F6"
  end

  def custom_footer_text
    @account&.settings&.dig("footer_text") || "Default Footer"
  end
end
```

## Component Categories

### Layout Components (4)

#### ContentSectionComponent

Container component for page sections with responsive padding and backgrounds.

**Props:**
- `container`: `:narrow` | `:default` | `:wide` | `:full` | `:none` (default: `:default`)
- `padding`: `:none` | `:sm` | `:default` | `:lg` | `:xl` (default: `:default`)
- `background`: `:white` | `:gray` | `:dark` | `:primary` | `:transparent` (default: `:white`)
- `id`: String (optional)
- `class_name`: String (optional)

**Example:**
```ruby
render ContentSectionComponent.new(
  container: :narrow,
  padding: :lg,
  background: :gray
) do
  h2 { "Section Title" }
  p { "Section content..." }
end
```

**Tailwind Classes:**
- Container: `max-w-4xl`, `max-w-7xl`, `max-w-screen-2xl`, `w-full`
- Padding: `py-4 sm:py-6 lg:py-8` through `py-20 sm:py-24 lg:py-32`
- Background: `bg-white`, `bg-gray-50`, `bg-gray-900`, `bg-blue-600`

#### FooterComponent

Multi-column footer with tenant branding, social links, and copyright.

**Props:**
- `account`: Account (optional, defaults to `Current.account`)
- `columns`: Array of `{title:, links: [{text:, url:}]}`
- `copyright_text`: String (optional)
- `logo_url`: String (optional)
- `social_links`: Array of `{icon:, url:, label:}`

**Example:**
```ruby
render FooterComponent.new(
  account: Current.account,
  columns: [
    {
      title: "Company",
      links: [
        {text: "About", url: "/about"},
        {text: "Careers", url: "/careers"}
      ]
    }
  ],
  social_links: [
    {icon: :twitter, url: "https://twitter.com/company", label: "Twitter"}
  ]
)
```

**Tailwind Classes:**
- Layout: `grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8`
- Colors: `bg-gray-900 text-white`
- Links: `text-gray-400 hover:text-white transition-colors duration-200`

#### HeroComponent

Large hero section with background images, CTAs, and responsive text.

**Props:**
- `title`: String (required)
- `subtitle`: String (optional)
- `primary_cta`: `{text:, url:}` (optional)
- `secondary_cta`: `{text:, url:}` (optional)
- `background_image`: String URL (optional)
- `background_color`: `:gradient` | `:primary` | `:dark` | `:white` (default: `:gradient`)
- `text_alignment`: `:center` | `:left` | `:right` (default: `:center`)
- `height`: `:sm` | `:default` | `:lg` | `:full` (default: `:default`)

**Example:**
```ruby
render HeroComponent.new(
  title: "Welcome to Our Platform",
  subtitle: "Build amazing things together",
  primary_cta: {text: "Get Started", url: "/signup"},
  secondary_cta: {text: "Learn More", url: "/about"},
  background_color: :gradient,
  height: :lg
)
```

**Tailwind Classes:**
- Heights: `min-h-[40vh]`, `min-h-[60vh]`, `min-h-[80vh]`, `min-h-screen`
- Text: `text-4xl sm:text-5xl md:text-6xl lg:text-7xl`
- Buttons: `px-6 sm:px-8 py-3 sm:py-4 text-base sm:text-lg`
- Background: `bg-gradient-to-br from-blue-600 via-blue-700 to-indigo-800`

#### NavigationComponent

Responsive navigation bar with logo, menu items, user dropdown, and mobile menu.

**Props:**
- `logo_url`: String (optional)
- `logo_text`: String (optional, defaults to account name)
- `menu_items`: Array of `{text:, url:, children: []}`
- `current_user`: User (optional)
- `account`: Account (optional)
- `sticky`: Boolean (default: `true`)
- `transparent`: Boolean (default: `false`)

**Example:**
```ruby
render NavigationComponent.new(
  logo_text: Current.account&.name,
  menu_items: [
    {text: "Home", url: "/"},
    {
      text: "Products",
      url: "#",
      children: [
        {text: "Product A", url: "/products/a"},
        {text: "Product B", url: "/products/b"}
      ]
    }
  ],
  current_user: current_user,
  sticky: true
)
```

**Stimulus Controllers:** `navigation`, `dropdown`

**Tailwind Classes:**
- Layout: `sticky top-0 z-50 border-b border-gray-200 bg-white`
- Desktop menu: `hidden md:flex md:items-center md:space-x-8`
- Mobile menu: `hidden md:hidden border-t border-gray-200`

### Form Components (10)

#### InputComponent

Text input with label, validation states, hints, and error messages.

**Props:**
- `name`: String (required)
- `type`: Symbol (default: `:text`)
- `value`: String (optional)
- `placeholder`: String (optional)
- `disabled`: Boolean (default: `false`)
- `required`: Boolean (default: `false`)
- `validation_state`: `:error` | `:success` | `:warning` (optional)
- `error_message`: String (optional)
- `hint`: String (optional)
- `label`: String (optional)
- `id`: String (optional)

**Example:**
```ruby
render InputComponent.new(
  name: "email",
  type: :email,
  label: "Email Address",
  placeholder: "you@example.com",
  required: true,
  hint: "We'll never share your email",
  validation_state: :error,
  error_message: "Email is required"
)
```

**Stimulus Controller:** `input`

**Tailwind Classes:**
- Base: `block w-full rounded-md shadow-sm sm:text-sm`
- Valid: `border-gray-300 focus:ring-blue-500 focus:border-blue-500`
- Error: `border-red-300 text-red-900 focus:ring-red-500`
- Success: `border-green-300 focus:ring-green-500`

#### TextareaComponent

Multi-line text input with auto-resize and character count.

**Props:**
- `name`: String (required)
- `value`: String (optional)
- `placeholder`: String (optional)
- `rows`: Integer (default: `3`)
- `max_length`: Integer (optional)
- `disabled`: Boolean (default: `false`)
- `required`: Boolean (default: `false`)
- `label`: String (optional)
- `hint`: String (optional)

**Stimulus Controller:** `textarea`

#### CheckboxComponent

Checkbox input with label and description.

**Props:**
- `name`: String (required)
- `checked`: Boolean (default: `false`)
- `label`: String (optional)
- `description`: String (optional)
- `disabled`: Boolean (default: `false`)

#### SelectComponent

Dropdown select with searchable options.

**Props:**
- `name`: String (required)
- `options`: Array of `{value:, label:}` or simple values
- `selected`: String (optional)
- `placeholder`: String (optional)
- `label`: String (optional)
- `disabled`: Boolean (default: `false`)

#### RadioGroupComponent

Group of radio button options.

**Props:**
- `name`: String (required)
- `options`: Array of `{value:, label:, description:}`
- `selected`: String (optional)
- `orientation`: `:vertical` | `:horizontal` (default: `:vertical`)

#### SwitchComponent

Toggle switch for boolean values.

**Props:**
- `name`: String (required)
- `checked`: Boolean (default: `false`)
- `label`: String (optional)
- `disabled`: Boolean (default: `false`)

#### SliderComponent

Range slider for numeric input.

**Props:**
- `name`: String (required)
- `min`: Number (default: `0`)
- `max`: Number (default: `100`)
- `step`: Number (default: `1`)
- `value`: Number (optional)
- `label`: String (optional)

**Stimulus Controller:** `slider`

#### LabelComponent

Accessible form label.

**Props:**
- `for`: String (required)
- `text`: String (required)
- `required`: Boolean (default: `false`)

**Stimulus Controller:** `label`

### Feedback Components (7)

#### AlertComponent

Dismissible alert messages for notifications.

**Props:**
- `variant`: `:info` | `:success` | `:warning` | `:error` (default: `:info`)
- `title`: String (optional)
- `message`: String (required)
- `dismissible`: Boolean (default: `true`)

**Example:**
```ruby
render AlertComponent.new(
  variant: :success,
  title: "Success!",
  message: "Your changes have been saved.",
  dismissible: true
)
```

**Tailwind Classes:**
- Info: `bg-blue-50 border-blue-200 text-blue-800`
- Success: `bg-green-50 border-green-200 text-green-800`
- Warning: `bg-yellow-50 border-yellow-200 text-yellow-800`
- Error: `bg-red-50 border-red-200 text-red-800`

#### ToastComponent / ToasterComponent

Toast notifications for temporary feedback.

**Props:**
- `message`: String (required)
- `variant`: `:default` | `:success` | `:error` (default: `:default`)
- `duration`: Integer milliseconds (default: `3000`)

**Stimulus Controller:** `toast`

#### ProgressComponent

Progress bar for loading states.

**Props:**
- `value`: Number (0-100)
- `max`: Number (default: `100`)
- `variant`: `:default` | `:success` | `:warning` | `:error`
- `show_label`: Boolean (default: `true`)

#### BadgeComponent

Small badge for labels and counts.

**Props:**
- `text`: String (required)
- `variant`: `:default` | `:primary` | `:secondary` | `:success` | `:warning` | `:error`
- `size`: `:sm` | `:md` | `:lg`
- `removable`: Boolean (default: `false`)

#### SkeletonComponent

Loading skeleton for content placeholders.

**Props:**
- `width`: String (CSS width)
- `height`: String (CSS height)
- `circle`: Boolean (default: `false`)

#### SonnerComponent

Advanced toast notification system.

### Data Display Components (8)

#### TableComponent

Sortable, selectable, paginated data table.

**Props:**
- `data`: Array (required)
- `columns`: Array of `{key:, label:, format:, sortable:}`
- `sortable`: Boolean (default: `false`)
- `selectable`: Boolean (default: `false`)
- `paginated`: Boolean (default: `false`)
- `per_page`: Integer (default: `10`)
- `current_page`: Integer (default: `1`)
- `striped`: Boolean (default: `true`)
- `hoverable`: Boolean (default: `true`)

**Example:**
```ruby
render TableComponent.new(
  data: @users,
  columns: [
    {key: :name, label: "Name", sortable: true},
    {
      key: :email,
      label: "Email",
      format: ->(value, row) { link_to value, "mailto:#{value}" }
    },
    {key: :created_at, label: "Joined", format: ->(v, r) { v.strftime("%B %d, %Y") }}
  ],
  sortable: true,
  selectable: true,
  paginated: true
)
```

**Stimulus Controller:** `table`

**Tailwind Classes:**
- Container: `overflow-x-auto`
- Header: `text-xs text-gray-700 uppercase bg-gray-50`
- Rows: `hover:bg-gray-100` (if hoverable)
- Striped: `bg-gray-50` (even rows)

#### CardComponent

Container card with optional header and footer.

**Props:**
- `title`: String (optional)
- `footer`: String/Component (optional)

**Example:**
```ruby
render CardComponent.new(title: "User Profile") do
  p { "Card content here" }
end
```

#### AvatarComponent

User avatar with image or initials.

**Props:**
- `src`: String URL (optional)
- `initials`: String (optional)
- `size`: `:sm` | `:md` | `:lg` (default: `:md`)

**Tailwind Classes:**
- Small: `h-8 w-8 text-xs`
- Medium: `h-12 w-12 text-base`
- Large: `h-16 w-16 text-xl`

#### BreadcrumbComponent

Navigation breadcrumb trail.

**Props:**
- `items`: Array of `{text:, url:}` (last item auto-styled as current)

#### PaginationComponent

Page navigation for long lists.

**Props:**
- `current_page`: Integer (required)
- `total_pages`: Integer (required)
- `url_pattern`: String with `:page` placeholder

#### SeparatorComponent

Visual divider between sections.

**Props:**
- `orientation`: `:horizontal` | `:vertical` (default: `:horizontal`)
- `spacing`: `:sm` | `:md` | `:lg` (default: `:md`)

#### ChartComponent

Chart wrapper for data visualization.

**Props:**
- `type`: `:line` | `:bar` | `:pie` (required)
- `data`: Hash (required)
- `options`: Hash (optional)

**Stimulus Controller:** `chart`

#### AspectRatioComponent

Maintain aspect ratio for responsive media.

**Props:**
- `ratio`: String (e.g., "16/9", "4/3", "1/1")

### Interactive Components (12)

#### ButtonComponent

Clickable button with variants and sizes.

**Props:**
- `text`: String (required)
- `type`: `:button` | `:submit` | `:reset` (default: `:button`)
- `variant`: `:default` | `:primary` | `:secondary` | `:danger` (default: `:default`)
- `size`: `:sm` | `:md` | `:lg` (default: `:md`)
- `disabled`: Boolean (default: `false`)

**Example:**
```ruby
render ButtonComponent.new(
  text: "Save Changes",
  variant: :primary,
  type: :submit
)
```

**Tailwind Classes:**
- Primary: `text-white bg-blue-700 hover:bg-blue-800 focus:ring-blue-300`
- Secondary: `text-gray-900 bg-white border hover:bg-gray-100`
- Danger: `text-white bg-red-700 hover:bg-red-800`

#### DialogComponent / AlertDialogComponent

Modal dialogs for confirmations and forms.

**Props:**
- `title`: String (required)
- `open`: Boolean (default: `false`)
- `size`: `:sm` | `:md` | `:lg` | `:xl` (default: `:md`)

**Stimulus Controllers:** `dialog`, `alert_dialog`

#### DrawerComponent / SheetComponent

Slide-out panels from screen edges.

**Props:**
- `position`: `:left` | `:right` | `:top` | `:bottom` (default: `:right`)
- `size`: `:sm` | `:md` | `:lg` (default: `:md`)
- `open`: Boolean (default: `false`)

**Stimulus Controllers:** `drawer`, `sheet`

#### PopoverComponent

Floating content popup.

**Props:**
- `trigger`: Component (required)
- `position`: `:top` | `:bottom` | `:left` | `:right` (default: `:bottom`)
- `align`: `:start` | `:center` | `:end` (default: `:center`)

**Stimulus Controller:** `popover`

#### TooltipComponent

Hover tooltip for additional info.

**Props:**
- `text`: String (required)
- `position`: `:top` | `:bottom` | `:left` | `:right` (default: `:top`)

**Stimulus Controller:** `tooltip`

#### DropdownMenuComponent

Dropdown menu with options.

**Props:**
- `trigger`: String/Component (required)
- `items`: Array of `{text:, url:, action:, divider:}`
- `align`: `:start` | `:end` (default: `:start`)

**Stimulus Controller:** `dropdown_menu`

#### AccordionComponent

Collapsible content sections.

**Props:**
- `items`: Array of `{title:, content:}`
- `allow_multiple`: Boolean (default: `false`)

**Stimulus Controller:** `accordion`

#### CollapsibleComponent

Single collapsible section.

**Props:**
- `title`: String (required)
- `open`: Boolean (default: `false`)

**Stimulus Controller:** `collapsible`

#### HoverCardComponent

Card that appears on hover.

**Props:**
- `trigger`: Component (required)
- `delay`: Integer milliseconds (default: `200`)

**Stimulus Controller:** `hover_card`

#### ContextMenuComponent

Right-click context menu.

**Props:**
- `items`: Array of menu items

**Stimulus Controller:** `context_menu`

#### CommandComponent

Command palette for keyboard navigation.

**Props:**
- `commands`: Array of `{name:, action:, shortcut:}`
- `placeholder`: String (default: "Type a command...")

**Stimulus Controller:** `command`

#### MenubarComponent

Application menu bar.

**Props:**
- `menus`: Array of `{label:, items: []}`

**Stimulus Controller:** `menubar`

### Utility Components (7)

#### ScrollAreaComponent

Custom scrollable container.

**Props:**
- `height`: String CSS height
- `orientation`: `:vertical` | `:horizontal` | `:both` (default: `:vertical`)

**Stimulus Controller:** `scroll_area`

#### ResizableComponent

Resizable panels with drag handles.

**Props:**
- `panels`: Array of `{content:, size:, min_size:}`
- `direction`: `:horizontal` | `:vertical` (default: `:horizontal`)

**Stimulus Controller:** `resizable`

#### CarouselComponent

Image/content carousel with navigation.

**Props:**
- `items`: Array of content
- `auto_play`: Boolean (default: `false`)
- `interval`: Integer milliseconds (default: `3000`)

**Stimulus Controller:** `carousel`

#### CalendarComponent

Date picker calendar.

**Props:**
- `selected_date`: Date (optional)
- `min_date`: Date (optional)
- `max_date`: Date (optional)

**Stimulus Controller:** `calendar`

#### ToggleComponent / ToggleGroupComponent

Toggle buttons for options.

**Props:**
- `pressed`: Boolean (default: `false`)
- `disabled`: Boolean (default: `false`)

### Specialized Components (1)

#### WorkspaceSwitcherComponent

Tenant-aware workspace switcher showing accounts and workspaces.

**Props:**
- `current_user`: User (required)
- `current_workspace`: Workspace (optional)

**Example:**
```ruby
render WorkspaceSwitcherComponent.new(
  current_user: current_user,
  current_workspace: current_user.current_workspace
)
```

**Multi-Tenant Features:**
- Groups workspaces by account
- Shows only workspaces user has access to
- Highlights current workspace
- Handles account switching

**Tailwind Classes:**
- Trigger: `w-64 px-4 py-2 text-sm border rounded-lg hover:bg-gray-50`
- Dropdown: `w-64 rounded-md shadow-lg bg-white max-h-96 overflow-y-auto`

## Usage Examples

### Basic Component

```ruby
# In view (ERB)
<%= render ButtonComponent.new(text: "Click Me", variant: :primary) %>

# In Phlex component
render ButtonComponent.new(text: "Click Me", variant: :primary)
```

### Component with Block Content

```ruby
render CardComponent.new(title: "My Card") do
  p { "This is card content" }
  render ButtonComponent.new(text: "Action")
end
```

### Passing Tenant Context

```ruby
# Option 1: Explicit account
render FooterComponent.new(account: Current.account)

# Option 2: Component reads Current.account internally
render FooterComponent.new # Uses Current.account by default
```

### Tenant-Scoped Data

```ruby
# Controller
@projects = Current.account.projects.active

# View
render ProjectListComponent.new(projects: @projects)

# Component
class ProjectListComponent < Phlex::HTML
  def initialize(projects:)
    @projects = projects # Already scoped to tenant
  end

  def template
    ul do
      @projects.each do |project|
        li { project.name }
      end
    end
  end
end
```

### Conditional Tenant Features

```ruby
class FeatureComponent < Phlex::HTML
  def template
    # Check tenant's plan for feature access
    if Current.account&.plan&.include?("premium")
      render_premium_feature
    else
      render_basic_feature
    end
  end
end
```

## Testing Components

### RSpec Test Structure

```ruby
# spec/components/my_component_spec.rb
require "rails_helper"

RSpec.describe MyComponent, type: :component do
  it "renders with default props" do
    output = render_inline(described_class.new)
    expect(output.to_html).to include("expected content")
  end

  it "applies variant classes" do
    output = render_inline(described_class.new(variant: :primary))
    expect(output.to_html).to include("bg-blue-600")
  end
end
```

### Testing with Tenant Context

```ruby
RSpec.describe FooterComponent, type: :component do
  let(:account) { create(:account, name: "Test Co") }

  it "displays tenant name" do
    output = render_inline(described_class.new(account: account))
    expect(output.to_html).to include("Test Co")
  end

  it "uses Current.account when not provided" do
    Current.account = account
    output = render_inline(described_class.new)
    expect(output.to_html).to include("Test Co")
  end
end
```

### Testing Responsive Behavior

```ruby
it "applies responsive classes" do
  output = render_inline(described_class.new)
  html = output.to_html

  expect(html).to include("grid-cols-1")
  expect(html).to include("md:grid-cols-2")
  expect(html).to include("lg:grid-cols-4")
end
```

## Styling Conventions

### Tailwind Class Organization

Components follow a consistent class ordering:

1. Layout: `block`, `flex`, `grid`, `inline-flex`
2. Sizing: `w-full`, `h-12`, `max-w-4xl`
3. Spacing: `p-4`, `m-2`, `space-x-4`, `gap-4`
4. Typography: `text-sm`, `font-medium`, `tracking-tight`
5. Colors: `bg-white`, `text-gray-900`, `border-gray-200`
6. Effects: `shadow-lg`, `rounded-lg`, `opacity-50`
7. Interactions: `hover:bg-gray-100`, `focus:ring-2`
8. Responsive: `sm:text-lg`, `md:grid-cols-2`, `lg:px-8`
9. States: `disabled:opacity-50`, `dark:bg-gray-800`

### Responsive Breakpoints

- `sm`: 640px
- `md`: 768px
- `lg`: 1024px
- `xl`: 1280px
- `2xl`: 1536px

### Color Palette

Primary colors from Tailwind:
- Blue: Primary actions (`blue-600`, `blue-700`)
- Gray: Neutral UI (`gray-50` through `gray-900`)
- Red: Errors/Danger (`red-600`, `red-700`)
- Green: Success (`green-600`, `green-700`)
- Yellow: Warnings (`yellow-600`, `yellow-700`)

### Component Patterns

#### Private Methods for Classes

```ruby
def template
  button(class: button_classes) { @text }
end

private

def button_classes
  "#{base_classes} #{variant_classes} #{size_classes}"
end
```

#### Conditional Rendering

```ruby
def template
  div do
    render_header if @title
    render_content
    render_footer if @footer
  end
end
```

#### Accessing Rails Helpers

```ruby
def helpers
  ApplicationController.helpers
end

def template
  a(href: helpers.root_path) { "Home" }
end
```

## Contributing

When creating new components:

1. Follow the established naming convention: `*_component.rb`
2. Include proper props with defaults in `initialize`
3. Use responsive Tailwind classes
4. Support tenant context when relevant
5. Add Stimulus controllers for interactivity
6. Write comprehensive RSpec tests
7. Update this README with usage examples

## Additional Resources

- [Phlex Documentation](https://www.phlex.fun/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Stimulus Documentation](https://stimulus.hotwired.dev/)
- [Rails Multi-Tenant Guide](docs/rails_conventions.md)
