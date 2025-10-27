# Tenant-Scoped Component Patterns

This document describes patterns for building multi-tenant aware Phlex components that integrate with the `Current.account` context and provide tenant-specific customization.

## Overview

In a multi-tenant Rails application, components often need to:
1. Display tenant-specific content (logos, names, descriptions)
2. Apply tenant-specific styles (brand colors, custom CSS)
3. Respect tenant-specific feature flags or plan limitations
4. Work with tenant-scoped data

## Accessing Tenant Context

### Pattern 1: Explicit Account Parameter (Recommended)

Pass the account explicitly and fall back to `Current.account`:

```ruby
class BrandedHeaderComponent < Phlex::HTML
  def initialize(account: nil, title: "Welcome")
    @account = account || Current.account
    @title = title
  end

  def template
    header(class: "bg-white shadow") do
      div(class: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4") do
        div(class: "flex items-center justify-between") do
          render_logo
          h1(class: "text-2xl font-bold", style: "color: #{brand_color}") { @title }
        end
      end
    end
  end

  private

  def render_logo
    return unless @account&.logo_url

    img(src: @account.logo_url, alt: "#{@account.name} Logo", class: "h-10 w-auto")
  end

  def brand_color
    @account&.settings&.dig("brand_color") || "#3B82F6"
  end
end
```

**Usage:**
```ruby
# Explicit account
render BrandedHeaderComponent.new(account: Current.account, title: "Dashboard")

# Fallback to Current.account
render BrandedHeaderComponent.new(title: "Dashboard")
```

### Pattern 2: Reading Current.account Directly

For components that always use the current tenant:

```ruby
class TenantFeatureToggleComponent < Phlex::HTML
  def initialize(feature_name:, enabled_content:, disabled_content: nil)
    @feature_name = feature_name
    @enabled_content = enabled_content
    @disabled_content = disabled_content
  end

  def template
    if feature_enabled?
      div(class: "feature-enabled") { @enabled_content }
    elsif @disabled_content
      div(class: "feature-disabled") { @disabled_content }
    end
  end

  private

  def feature_enabled?
    Current.account&.plan&.include?(@feature_name) || false
  end
end
```

## Tenant-Specific Branding

### Brand Colors

```ruby
class BrandedButtonComponent < Phlex::HTML
  def initialize(text:, account: nil, variant: :primary)
    @text = text
    @account = account || Current.account
    @variant = variant
  end

  def template
    button(
      type: "button",
      class: base_classes,
      style: button_styles
    ) { @text }
  end

  private

  def base_classes
    "px-4 py-2 rounded-lg font-medium transition-colors duration-200"
  end

  def button_styles
    case @variant
    when :primary
      "background-color: #{primary_color}; color: white;"
    when :secondary
      "border: 2px solid #{primary_color}; color: #{primary_color};"
    else
      ""
    end
  end

  def primary_color
    @account&.settings&.dig("brand_color") || "#3B82F6"
  end
end
```

### Custom CSS Classes

```ruby
class ThemeableCardComponent < Phlex::HTML
  def initialize(account: nil)
    @account = account || Current.account
  end

  def template(&)
    div(class: card_classes, &)
  end

  private

  def card_classes
    base = "rounded-lg shadow p-6"
    theme = @account&.settings&.dig("card_theme") || "light"

    case theme
    when "dark"
      "#{base} bg-gray-900 text-white"
    when "brand"
      "#{base} bg-blue-50 border-2 border-blue-200"
    else
      "#{base} bg-white"
    end
  end
end
```

### Tenant Logo and Imagery

```ruby
class TenantFooterComponent < Phlex::HTML
  def initialize(account: nil)
    @account = account || Current.account
  end

  def template
    footer(class: "bg-gray-900 text-white py-12") do
      div(class: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8") do
        div(class: "flex flex-col md:flex-row justify-between items-center") do
          render_branding
          render_links
          render_copyright
        end
      end
    end
  end

  private

  def render_branding
    div(class: "mb-6 md:mb-0") do
      if @account&.logo_url
        img(src: @account.logo_url, alt: "Logo", class: "h-12 w-auto mb-2")
      end

      if @account&.settings&.dig("footer_tagline")
        p(class: "text-gray-400 text-sm") { @account.settings["footer_tagline"] }
      end
    end
  end

  def render_links
    # Custom footer links from tenant settings
    links = @account&.settings&.dig("footer_links") || default_links

    nav(class: "flex space-x-6 mb-6 md:mb-0") do
      links.each do |link|
        a(href: link["url"], class: "text-gray-400 hover:text-white transition-colors") do
          link["text"]
        end
      end
    end
  end

  def render_copyright
    p(class: "text-gray-400 text-sm") do
      "© #{Time.current.year} #{@account&.name || 'Company'}. All rights reserved."
    end
  end

  def default_links
    [
      {"text" => "Privacy", "url" => "/privacy"},
      {"text" => "Terms", "url" => "/terms"}
    ]
  end
end
```

## Feature Gating by Tenant Plan

### Conditional Rendering

```ruby
class PremiumFeatureComponent < Phlex::HTML
  def initialize(account: nil, feature: :advanced_analytics)
    @account = account || Current.account
    @feature = feature
  end

  def template
    if has_feature?
      render_feature_content
    else
      render_upgrade_prompt
    end
  end

  private

  def has_feature?
    return false unless @account

    case @account.plan
    when "enterprise"
      true
    when "premium"
      [:advanced_analytics, :api_access].include?(@feature)
    when "basic"
      [:basic_analytics].include?(@feature)
    else
      false
    end
  end

  def render_feature_content
    div(class: "feature-content") do
      yield if block_given?
    end
  end

  def render_upgrade_prompt
    div(class: "upgrade-prompt bg-gray-50 border-2 border-gray-200 rounded-lg p-6") do
      h3(class: "text-lg font-semibold mb-2") { "Upgrade Required" }
      p(class: "text-gray-600 mb-4") do
        "This feature is available on Premium and Enterprise plans."
      end
      a(
        href: "/billing/upgrade",
        class: "inline-block px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
      ) { "Upgrade Now" }
    end
  end
end
```

## Working with Tenant-Scoped Data

### Displaying Tenant Data Lists

```ruby
class ProjectListComponent < Phlex::HTML
  def initialize(projects:, account: nil)
    @projects = projects # Already scoped by controller
    @account = account || Current.account
  end

  def template
    div(class: "space-y-4") do
      if @projects.any?
        @projects.each do |project|
          render_project_card(project)
        end
      else
        render_empty_state
      end
    end
  end

  private

  def render_project_card(project)
    div(class: "bg-white shadow rounded-lg p-6") do
      h3(class: "text-lg font-semibold mb-2") { project.name }
      p(class: "text-gray-600") { project.description }

      # Verify project belongs to current account (safety check)
      if project.account_id != @account.id
        div(class: "bg-red-50 text-red-800 p-2 rounded mt-2") do
          "Warning: Cross-tenant data detected"
        end
      end
    end
  end

  def render_empty_state
    div(class: "text-center py-12 text-gray-500") do
      p { "No projects found" }
      a(href: "/projects/new", class: "text-blue-600 hover:underline") do
        "Create your first project"
      end
    end
  end
end
```

### Data Validation in Components

```ruby
class TenantDataTableComponent < Phlex::HTML
  def initialize(data:, account: nil)
    @data = data
    @account = account || Current.account
    validate_tenant_scope!
  end

  def template
    table(class: "w-full") do
      thead { render_headers }
      tbody { render_rows }
    end
  end

  private

  def validate_tenant_scope!
    return unless @account
    return if @data.empty?

    # Ensure all records belong to the current account
    foreign_records = @data.reject { |record| record.account_id == @account.id }

    if foreign_records.any?
      raise SecurityError, "Attempted to render data from #{foreign_records.count} foreign tenant(s)"
    end
  end

  def render_headers
    tr do
      th { "Name" }
      th { "Status" }
      th { "Actions" }
    end
  end

  def render_rows
    @data.each do |record|
      tr do
        td { record.name }
        td { record.status }
        td { render_actions(record) }
      end
    end
  end

  def render_actions(record)
    a(href: "/items/#{record.id}", class: "text-blue-600 hover:underline") { "View" }
  end
end
```

## Testing Tenant-Scoped Components

### Basic Tenant Context Test

```ruby
RSpec.describe BrandedHeaderComponent, type: :component do
  let(:account) { create(:account, name: "Acme Corp", logo_url: "https://example.com/logo.png") }

  describe "with explicit account" do
    it "renders account logo" do
      page = render_inline(described_class.new(account: account))
      expect(page).to have_css("img[src='https://example.com/logo.png']")
    end

    it "uses account name" do
      page = render_inline(described_class.new(account: account))
      expect(page).to have_text("Acme Corp")
    end
  end

  describe "with Current.account" do
    before { Current.account = account }
    after { Current.account = nil }

    it "uses Current.account when not provided" do
      page = render_inline(described_class.new)
      expect(page).to have_text("Acme Corp")
    end
  end

  describe "without account" do
    it "renders gracefully" do
      page = render_inline(described_class.new)
      expect(page).to have_css("header")
    end
  end
end
```

### Testing Tenant Branding

```ruby
RSpec.describe BrandedButtonComponent, type: :component do
  describe "with custom brand color" do
    let(:account) { create(:account, settings: {"brand_color" => "#FF0000"}) }

    it "applies tenant brand color" do
      component = described_class.new(text: "Click me", account: account)
      html = Phlex::Testing::ViewContext.new.render(component)

      expect(html).to include("background-color: #FF0000")
    end
  end

  describe "without brand color" do
    let(:account) { create(:account, settings: {}) }

    it "uses default color" do
      component = described_class.new(text: "Click me", account: account)
      html = Phlex::Testing::ViewContext.new.render(component)

      expect(html).to include("background-color: #3B82F6")
    end
  end
end
```

### Testing Feature Gating

```ruby
RSpec.describe PremiumFeatureComponent, type: :component do
  describe "with enterprise account" do
    let(:account) { create(:account, plan: "enterprise") }

    it "renders feature content" do
      page = render_inline(described_class.new(account: account, feature: :advanced_analytics))
      expect(page).to have_css(".feature-content")
      expect(page).not_to have_text("Upgrade Required")
    end
  end

  describe "with basic account" do
    let(:account) { create(:account, plan: "basic") }

    it "renders upgrade prompt for premium features" do
      page = render_inline(described_class.new(account: account, feature: :advanced_analytics))
      expect(page).to have_css(".upgrade-prompt")
      expect(page).to have_text("Upgrade Required")
    end
  end
end
```

### Testing Cross-Tenant Protection

```ruby
RSpec.describe TenantDataTableComponent, type: :component do
  let(:account1) { create(:account) }
  let(:account2) { create(:account) }
  let(:own_data) { create_list(:item, 3, account: account1) }
  let(:foreign_data) { create_list(:item, 2, account: account2) }

  it "accepts data from own account" do
    expect {
      render_inline(described_class.new(data: own_data, account: account1))
    }.not_to raise_error
  end

  it "rejects data from foreign account" do
    mixed_data = own_data + foreign_data

    expect {
      render_inline(described_class.new(data: mixed_data, account: account1))
    }.to raise_error(SecurityError, /foreign tenant/)
  end
end
```

## Best Practices

### 1. Always Validate Tenant Scope

When accepting ActiveRecord objects, validate they belong to the expected tenant:

```ruby
def initialize(project:, account: nil)
  @project = project
  @account = account || Current.account

  if @account && @project.account_id != @account.id
    raise SecurityError, "Cross-tenant access denied"
  end
end
```

### 2. Provide Sensible Defaults

Components should work without explicit tenant data:

```ruby
def brand_color
  @account&.settings&.dig("brand_color") || "#3B82F6" # Default blue
end

def logo_url
  @account&.logo_url || "/default-logo.png"
end
```

### 3. Document Tenant Requirements

Use comments to document when components require tenant context:

```ruby
# TenantDashboardComponent requires an account to display metrics.
# Pass explicitly or ensure Current.account is set.
class TenantDashboardComponent < Phlex::HTML
  # ...
end
```

### 4. Avoid Database Queries in Components

Pass pre-fetched, tenant-scoped data from controllers:

```ruby
# Good - data pre-fetched in controller
class ProjectsController < ApplicationController
  def index
    @projects = Current.account.projects.active.includes(:members)
    render ProjectListComponent.new(projects: @projects)
  end
end

# Bad - querying in component
class ProjectListComponent < Phlex::HTML
  def template
    # Don't do this!
    projects = Current.account.projects.all
    # ...
  end
end
```

### 5. Use Tenant Settings as JSON

Store customization options in account.settings JSONB column:

```ruby
# Migration
add_column :accounts, :settings, :jsonb, default: {}, null: false
add_index :accounts, :settings, using: :gin

# Usage in components
def footer_links
  @account&.settings&.dig("footer_links") || []
end

def show_feature?(feature_key)
  @account&.settings&.dig("enabled_features", feature_key) || false
end
```

## Common Patterns by Component Type

### Navigation Components

```ruby
class TenantNavigationComponent < Phlex::HTML
  def initialize(account: nil, current_user: nil)
    @account = account || Current.account
    @current_user = current_user
  end

  def template
    nav(class: "bg-white shadow") do
      render_logo
      render_menu_items
      render_user_menu if @current_user
    end
  end

  private

  def menu_items
    # Custom navigation from tenant settings
    @account&.settings&.dig("nav_items") || default_nav_items
  end
end
```

### Form Components

```ruby
class TenantFormComponent < Phlex::HTML
  def initialize(model:, account: nil)
    @model = model
    @account = account || Current.account

    # Auto-set account_id if not set
    @model.account_id ||= @account&.id
  end

  def template
    form_with(model: @model) do |f|
      # Hidden account_id field
      f.hidden_field :account_id

      # Other form fields...
      yield f
    end
  end
end
```

### Display Components

```ruby
class TenantMetricsComponent < Phlex::HTML
  def initialize(metrics:, account: nil)
    @metrics = metrics
    @account = account || Current.account
  end

  def template
    div(class: "grid grid-cols-1 md:grid-cols-3 gap-4") do
      @metrics.each do |metric|
        render_metric_card(metric)
      end
    end
  end

  private

  def render_metric_card(metric)
    div(class: "bg-white shadow rounded-lg p-6") do
      h3(class: "text-sm font-medium text-gray-500") { metric[:label] }
      p(class: "text-3xl font-bold", style: "color: #{brand_color}") do
        metric[:value]
      end
    end
  end

  def brand_color
    @account&.settings&.dig("brand_color") || "#3B82F6"
  end
end
```

## Validation Requirements

### Input Validation Patterns

All components accepting user input must validate at the controller/service level:

```ruby
# Controller validates before passing to component
class ProjectsController < ApplicationController
  def create
    # SECURITY: Validate input before creating resource
    @project = Current.account.projects.build(project_params)

    if @project.valid?
      @project.save
      render ProjectComponent.new(project: @project)
    else
      # Return validation errors
      render json: { errors: @project.errors }, status: :unprocessable_entity
    end
  end

  private

  def project_params
    # SECURITY: Strong parameters to prevent mass assignment
    params.require(:project).permit(:name, :description, :status)
  end
end
```

### Tenant Scope Validation

Components handling tenant data must validate isolation:

```ruby
class TenantDataComponent < Phlex::HTML
  class TenantIsolationError < SecurityError; end

  def initialize(records:, account: nil, skip_validation: false)
    @records = records
    @account = account || Current.account
    @skip_validation = skip_validation

    validate_tenant_isolation! unless @skip_validation
  end

  private

  def validate_tenant_isolation!
    return if @records.empty?
    return unless @account

    # Check if records respond to account_id
    sample = @records.first
    return unless sample.respond_to?(:account_id)

    # Find any records not belonging to current account
    foreign_records = @records.select do |record|
      record.respond_to?(:account_id) && record.account_id != @account.id
    end

    if foreign_records.any?
      # Log security violation
      log_security_violation(foreign_records)

      # Raise error
      raise TenantIsolationError,
        "Attempted to render #{foreign_records.count} records from foreign tenant(s). " \
        "Current account: #{@account.id}, " \
        "Foreign account IDs: #{foreign_records.map(&:account_id).uniq.join(", ")}"
    end
  end

  def log_security_violation(foreign_records)
    Rails.logger.warn({
      event: "tenant_isolation_violation",
      component: self.class.name,
      current_account_id: @account.id,
      foreign_account_ids: foreign_records.map(&:account_id).uniq,
      record_count: foreign_records.count,
      user_id: Current.user&.id,
      backtrace: caller[0..5]
    }.to_json)
  end
end
```

### URL and Link Validation

Components rendering user-provided links must sanitize:

```ruby
class SafeLinkComponent < Phlex::HTML
  ALLOWED_PROTOCOLS = %w[http https mailto tel].freeze
  DANGEROUS_PROTOCOLS = %w[javascript data vbscript file].freeze

  def initialize(url:, text:, external: false)
    @url = sanitize_url(url)
    @text = text
    @external = external || url_is_external?(@url)
  end

  def template
    if @url
      a(
        href: @url,
        class: link_classes,
        rel: link_rel_attribute,
        target: @external ? "_blank" : nil
      ) { @text }
    else
      # Render as plain text if URL is invalid
      span(class: "text-gray-500 cursor-not-allowed") { @text }
    end
  end

  private

  def sanitize_url(url)
    return nil if url.blank?

    # Parse URL
    uri = URI.parse(url.to_s)

    # Block dangerous protocols
    if DANGEROUS_PROTOCOLS.include?(uri.scheme&.downcase)
      Rails.logger.security_warn(
        "Blocked dangerous URL protocol",
        protocol: uri.scheme,
        url: url,
        component: self.class.name
      )
      return nil
    end

    # Validate allowed protocols
    unless ALLOWED_PROTOCOLS.include?(uri.scheme&.downcase)
      Rails.logger.warn("Unknown URL protocol: #{uri.scheme}")
      return nil
    end

    url
  rescue URI::InvalidURIError => e
    Rails.logger.warn("Invalid URL format: #{url} - #{e.message}")
    nil
  end

  def url_is_external?(url)
    return false if url.blank?
    uri = URI.parse(url)
    uri.host.present? && uri.host != request.host
  rescue URI::InvalidURIError
    false
  end

  def link_rel_attribute
    # Prevent tabnabbing for external links
    @external ? "noopener noreferrer" : nil
  end

  def link_classes
    base = "text-blue-600 hover:text-blue-800 underline"
    @external ? "#{base} external-link" : base
  end
end
```

## Authorization Patterns

### Pundit Integration

Components should receive authorization results, not perform checks:

```ruby
# Good: Controller performs authorization
class WorkspacesController < ApplicationController
  def show
    @workspace = Current.account.workspaces.find(params[:id])

    # SECURITY: Authorize access via Pundit
    authorize @workspace

    # Pass authorization capabilities to component
    @can_edit = policy(@workspace).update?
    @can_delete = policy(@workspace).destroy?
    @can_invite = policy(@workspace).invite_members?

    render WorkspaceComponent.new(
      workspace: @workspace,
      can_edit: @can_edit,
      can_delete: @can_delete,
      can_invite: @can_invite
    )
  end
end

# Component renders based on passed capabilities
class WorkspaceComponent < Phlex::HTML
  def initialize(workspace:, can_edit: false, can_delete: false, can_invite: false)
    @workspace = workspace
    @can_edit = can_edit
    @can_delete = can_delete
    @can_invite = can_invite
  end

  def template
    div(class: "workspace-container") do
      render_header
      render_actions if @can_edit || @can_delete || @can_invite
    end
  end

  private

  def render_actions
    div(class: "flex gap-2") do
      render EditButton.new(workspace: @workspace) if @can_edit
      render InviteButton.new(workspace: @workspace) if @can_invite
      render DeleteButton.new(workspace: @workspace) if @can_delete
    end
  end
end
```

### Role-Based Rendering

```ruby
class AdminPanelComponent < Phlex::HTML
  def initialize(user:, account: nil)
    @user = user
    @account = account || Current.account
    @user_role = get_user_role
  end

  def template
    return unless authorized_to_view?

    div(class: "admin-panel") do
      render_header
      render_admin_sections
    end
  end

  private

  def authorized_to_view?
    # Users must be at least admin in the account
    %i[admin owner].include?(@user_role)
  end

  def render_admin_sections
    # Owner-only sections
    if @user_role == :owner
      render_billing_section
      render_member_management
      render_danger_zone
    end

    # Admin and owner sections
    if %i[admin owner].include?(@user_role)
      render_workspace_management
      render_team_management
    end
  end

  def get_user_role
    membership = @account.account_memberships.find_by(user: @user)
    membership&.role&.to_sym || :viewer
  end
end
```

### Row-Level Security

Components accessing workspace/team data must verify user access:

```ruby
class WorkspaceDataComponent < Phlex::HTML
  def initialize(workspace:, user:)
    @workspace = workspace
    @user = user

    # SECURITY: Verify user has access to workspace
    verify_workspace_access!
  end

  private

  def verify_workspace_access!
    membership = @workspace.workspace_memberships.find_by(user: @user, status: :active)

    unless membership
      raise Pundit::NotAuthorizedError,
        "User #{@user.id} does not have access to workspace #{@workspace.id}"
    end

    @user_role = membership.role.to_sym
  end

  def can_perform_action?(action)
    case action
    when :view
      true # All members can view
    when :edit
      %i[member admin owner].include?(@user_role)
    when :delete
      %i[admin owner].include?(@user_role)
    when :manage_members
      %i[admin owner].include?(@user_role)
    else
      false
    end
  end
end
```

## Performance Optimization Examples

### N+1 Query Prevention

Components must receive pre-loaded data:

```ruby
# Bad: Component triggers N+1 queries
class ProjectListComponent < Phlex::HTML
  def initialize(projects:)
    @projects = projects
  end

  def template
    @projects.each do |project|
      # N+1: queries members for each project
      p { "Members: #{project.members.count}" }
    end
  end
end

# Good: Controller preloads associations
class ProjectsController < ApplicationController
  def index
    # OPTIMIZE: Preload associations to prevent N+1
    @projects = Current.account.projects
      .includes(:workspace, :team_memberships, :members)
      .order(created_at: :desc)

    render ProjectListComponent.new(projects: @projects)
  end
end
```

### Caching Strategies

```ruby
class DashboardStatsComponent < Phlex::HTML
  def initialize(account:)
    @account = account
  end

  def template
    # Cache expensive stats calculation per account
    stats = Rails.cache.fetch(
      "account/#{@account.id}/dashboard_stats/v2",
      expires_in: 15.minutes
    ) do
      calculate_stats
    end

    div(class: "grid grid-cols-3 gap-4") do
      render_stat_card("Projects", stats[:project_count])
      render_stat_card("Members", stats[:member_count])
      render_stat_card("Workspaces", stats[:workspace_count])
    end
  end

  private

  def calculate_stats
    {
      project_count: @account.projects.count,
      member_count: @account.users.count,
      workspace_count: @account.workspaces.count
    }
  end
end
```

## Audit Logging Integration

### Tracking Component Actions

```ruby
class AuditedActionComponent < Phlex::HTML
  def initialize(resource:, action:, user:)
    @resource = resource
    @action = action
    @user = user
  end

  def template
    form(
      action: resource_path,
      method: "post",
      data: { turbo_confirm: confirmation_message }
    ) do
      # CSRF protection
      input(
        type: "hidden",
        name: "authenticity_token",
        value: helpers.form_authenticity_token
      )

      # Hidden fields for audit logging
      input(type: "hidden", name: "audit[action]", value: @action)
      input(type: "hidden", name: "audit[user_id]", value: @user.id)
      input(type: "hidden", name: "audit[resource_type]", value: @resource.class.name)
      input(type: "hidden", name: "audit[resource_id]", value: @resource.id)

      button(type: "submit", class: button_classes) { button_text }
    end
  end

  private

  def confirmation_message
    "Are you sure you want to #{@action} this #{@resource.class.name.downcase}?"
  end
end
```

### Audit Event Recording

Controllers should create audit events for component actions:

```ruby
class WorkspacesController < ApplicationController
  def destroy
    @workspace = Current.account.workspaces.find(params[:id])
    authorize @workspace

    # SECURITY: Create audit event before deletion
    AuditEvent.create!(
      action: "workspace_deleted",
      auditable: @workspace,
      user: current_user,
      account: Current.account,
      workspace: @workspace,
      metadata: {
        workspace_name: @workspace.name,
        workspace_slug: @workspace.slug,
        member_count: @workspace.workspace_memberships.count
      },
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )

    @workspace.destroy
    redirect_to workspaces_path, notice: "Workspace deleted"
  end
end
```

## Conclusion

Tenant-scoped components enhance multi-tenant applications by:
- Providing consistent branding across tenants
- Enforcing data isolation through validation
- Enabling per-tenant feature customization
- Maintaining security through validation and authorization
- Optimizing performance with proper data loading
- Creating audit trails for compliance

Always validate tenant scope, authorize access in controllers, provide sensible defaults, and test cross-tenant scenarios to ensure robust multi-tenant components.
