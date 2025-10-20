# Developer Workflows - Multi-Tenant Rails Application

This guide covers common development workflows for working with multi-tenant data in the Mangroves Rails application.

## Overview

The application uses a request-scoped tenancy pattern with `Current` (ActiveSupport::CurrentAttributes) to maintain tenant context throughout requests. For development, we provide rake tasks and console helpers to make it easy to work with tenant-scoped data.

### Tenant Hierarchy

- **Account** - Top-level organization (has billing/subscription)
- **Workspace** - Project/environment within an account
- **Team** - Collaboration group within workspace

### Current Context

Rails maintains thread-local context via `Current`:

```ruby
Current.account    # Current account
Current.workspace  # Current workspace
Current.user       # Current user
```

This context is set automatically in web requests by the `Authentication` concern, but must be set manually in console and rake tasks.

---

## Console Helpers

The console automatically loads helper methods for tenant management. Start the console:

```bash
bin/rails console
```

### `list_tenants`

List all accounts in the database with current context indicator.

**Example:**

```ruby
list_tenants
```

**Output:**

```
Available Accounts (2)
--------------------------------------------------------------------------------
SLUG                           NAME                           STATUS       USERS
--------------------------------------------------------------------------------
  acme-corp                      Acme Corporation               active          5
> test-account                   Test Account                   active          2
--------------------------------------------------------------------------------
```

The `>` indicator shows which account is currently active in `Current.account`.

---

### `switch_tenant(slug_or_account)`

Switch to a specific account for the console session. Sets both `Current.account` and `Current.workspace`.

**Parameters:**
- `slug_or_account` - String slug or Account object

**Example:**

```ruby
switch_tenant('acme-corp')
```

**Output:**

```
Switched to: Acme Corporation (acme-corp)
  Workspace: Default
  Users: 5
  Workspaces: 2
```

**Usage:**

```ruby
# Switch by slug
switch_tenant('acme-corp')

# Switch by account object
account = Account.find_by(slug: 'acme-corp')
switch_tenant(account)

# Now queries are scoped to this account
Project.count  # Only counts projects for acme-corp
```

---

### `show_tenant`

Display the current tenant context including account, workspace, and user.

**Example:**

```ruby
show_tenant
```

**Output:**

```
Current Tenant Context
------------------------------------------------------------
Account:    Acme Corporation (acme-corp)
Status:     active
Plan:       professional

Workspace:  Default (default)
Teams:      3

User:       (none)
------------------------------------------------------------
```

**Returns:** Hash with `{account:, workspace:, user:}` for further use.

---

### `with_tenant(slug_or_account) { block }`

Execute a block with a specific tenant context, then restore previous context. Useful for temporary context switching.

**Parameters:**
- `slug_or_account` - String slug or Account object
- Block to execute with tenant context

**Example:**

```ruby
# Current context: acme-corp
with_tenant('test-account') do
  # Temporarily in test-account context
  Project.create!(name: 'Test Project')
  puts Project.count  # Only test-account projects
end
# Back to acme-corp context
```

**Output:**

```
Switched to: Test Account (test-account)
Restored previous tenant
```

**Use Cases:**

```ruby
# Create data for multiple tenants
['acme-corp', 'test-account'].each do |slug|
  with_tenant(slug) do
    Project.create!(name: "New Project for #{Current.account.name}")
  end
end

# Query data across tenants
results = Account.all.map do |account|
  with_tenant(account) do
    {account: account.name, projects: Project.count}
  end
end
```

---

### `without_tenant { block }`

Execute a block without any tenant context. Useful for admin operations or cross-tenant queries.

**Example:**

```ruby
without_tenant do
  # No tenant scoping - sees all data
  Project.count  # Total across all accounts
  Account.all.each do |account|
    puts "#{account.name}: #{account.workspaces.count} workspaces"
  end
end
```

**Output:**

```
Cleared tenant context
Restored tenant context
```

**WARNING:** Be careful with write operations in `without_tenant` blocks. Models with `TenantScoped` may fail validations without `Current.account` set.

---

### `clear_tenant`

Clear all tenant context (sets Current.account, workspace, user to nil).

**Example:**

```ruby
clear_tenant
```

**Output:**

```
Tenant context cleared
```

**Use Case:**

```ruby
# Clear context to perform admin operations
clear_tenant
Account.all  # See all accounts without scoping
```

---

## Rake Tasks

All rake tasks are in the `tenant` namespace. Tasks can be run from the command line.

### `rake tenant:list`

List all accounts in the database.

**Usage:**

```bash
rake tenant:list
```

**Output:**

```
Accounts:
--------------------------------------------------------------------------------
SLUG                           NAME                           STATUS
--------------------------------------------------------------------------------
acme-corp                      Acme Corporation               active
test-account                   Test Account                   active
--------------------------------------------------------------------------------
Total: 2 accounts
```

---

### `rake tenant:switch[slug]`

Switch to a specific account by slug. Sets `Current.account` for the rake task.

**Usage:**

```bash
rake tenant:switch[acme-corp]
```

**Output:**

```
Switched to account: Acme Corporation (acme-corp)
  Status: active
  Workspaces: 2
  Users: 5

Note: This sets Current.account for this rake task only.
For console persistence, use: switch_tenant('acme-corp')
```

**Note:** Rake tasks run in separate processes, so context doesn't persist between tasks. Chain tasks if needed:

```bash
rake tenant:switch[acme-corp] tenant:info
```

---

### `rake tenant:create[name]`

Create a new account with a default workspace.

**Usage:**

```bash
rake tenant:create['New Company Inc']
```

**Output:**

```
Created account: New Company Inc
  Slug: new-company-inc
  ID: 123e4567-e89b-12d3-a456-426614174000
  Workspace: Default (default)

Next steps:
  1. Switch context: rake tenant:switch[new-company-inc]
```

**Slug Generation:** Automatically generates URL-friendly slug from name. If duplicate, appends number (e.g., `new-company-inc-2`).

---

### `rake tenant:info`

Show the current tenant context.

**Usage:**

```bash
rake tenant:info
```

**Output (with context):**

```
Current Account: Acme Corporation (acme-corp)
  ID: 123e4567-e89b-12d3-a456-426614174000
  Status: active
  Plan: professional

Current Workspace: Default (default)
  ID: 234e5678-e89b-12d3-a456-426614174000
  Account: Acme Corporation

No user context set (Current.user is nil)
```

**Output (without context):**

```
No tenant context set (Current.account is nil)
No workspace context set (Current.workspace is nil)
No user context set (Current.user is nil)
```

---

### `rake tenant:reset`

Reset all tenant context (clear Current.*).

**Usage:**

```bash
rake tenant:reset
```

**Output:**

```
Tenant context reset
  Current.account = nil
  Current.workspace = nil
  Current.user = nil
```

---

## Common Development Scenarios

### Scenario 1: Create Test Data for Multiple Tenants

You need to create sample projects for several accounts.

**Console:**

```ruby
# List available tenants
list_tenants

# Create projects for each tenant
['acme-corp', 'test-account', 'demo-org'].each do |slug|
  with_tenant(slug) do
    3.times do |i|
      Project.create!(
        name: "Project #{i + 1}",
        description: "Sample project for #{Current.account.name}"
      )
    end
    puts "Created 3 projects for #{Current.account.name}"
  end
end
```

---

### Scenario 2: Debug Cross-Tenant Data Leak

Verify that tenant scoping is working correctly.

**Console:**

```ruby
# Switch to first tenant
switch_tenant('acme-corp')
acme_projects = Project.all.to_a
puts "Acme projects: #{acme_projects.map(&:name)}"

# Switch to second tenant
switch_tenant('test-account')
test_projects = Project.all.to_a
puts "Test projects: #{test_projects.map(&:name)}"

# Verify no overlap
overlap = acme_projects & test_projects
puts "Overlap (should be empty): #{overlap.inspect}"

# Check without tenant context
without_tenant do
  all_projects = Project.unscoped.all
  puts "Total projects across all tenants: #{all_projects.count}"
end
```

---

### Scenario 3: Migrate Data Between Tenants

Move a project from one account to another.

**Console:**

```ruby
# Find project in source account
switch_tenant('source-account')
project = Project.find_by(name: 'My Project')

# Get project attributes (excluding tenant-specific fields)
attrs = project.attributes.except('id', 'account_id', 'created_at', 'updated_at')

# Create in destination account
switch_tenant('destination-account')
new_project = Project.create!(attrs)

puts "Migrated '#{project.name}' from source-account to destination-account"
puts "New project ID: #{new_project.id}"
```

---

### Scenario 4: Generate Tenant Report

Create a summary report of all accounts.

**Console:**

```ruby
report = Account.all.map do |account|
  with_tenant(account) do
    {
      name: account.name,
      slug: account.slug,
      status: account.status,
      plan: account.plan,
      workspaces: account.workspaces.count,
      teams: Workspace.joins(:teams).distinct.count(:team_id),
      users: account.users.count,
      projects: Project.count,
      created: account.created_at.strftime('%Y-%m-%d')
    }
  end
end

# Display as table
puts "\nAccount Report"
puts "-" * 120
printf "%-25s %-20s %-10s %-12s %5s %5s %5s %8s %12s\n",
  "NAME", "SLUG", "STATUS", "PLAN", "WS", "TEAMS", "USERS", "PROJECTS", "CREATED"
puts "-" * 120

report.each do |r|
  printf "%-25s %-20s %-10s %-12s %5d %5d %5d %8d %12s\n",
    r[:name].truncate(24),
    r[:slug].truncate(19),
    r[:status],
    r[:plan],
    r[:workspaces],
    r[:teams],
    r[:users],
    r[:projects],
    r[:created]
end

puts "-" * 120
```

---

## Best Practices

### 1. Always Set Context Before Querying Tenant Data

```ruby
# BAD - context may be nil or wrong
Project.count

# GOOD - explicit context
switch_tenant('acme-corp')
Project.count

# GOOD - temporary context
with_tenant('acme-corp') { Project.count }
```

### 2. Use `with_tenant` for Temporary Context Switches

```ruby
# BAD - manual context management
old_account = Current.account
Current.account = Account.find_by(slug: 'test')
result = Project.count
Current.account = old_account

# GOOD - automatic restoration
result = with_tenant('test') { Project.count }
```

### 3. Verify Context in Tests

```ruby
# In RSpec
RSpec.describe Project do
  let(:account) { create(:account) }

  before { Current.account = account }
  after { Current.reset }

  it "creates project in correct tenant" do
    project = create(:project)
    expect(project.account).to eq(account)
  end
end
```

### 4. Be Explicit with Cross-Tenant Operations

```ruby
# BAD - unclear intent
Account.all.each { |a| puts a.projects.count }

# GOOD - explicit scoping
Account.all.each do |account|
  without_tenant do
    puts "#{account.name}: #{account.projects.count} projects"
  end
end
```

### 5. Document Tenant Context Requirements

```ruby
# GOOD - document expected context
# Requires: Current.account to be set
def export_projects
  raise "No account context" unless Current.account

  Project.all.map(&:to_export_hash)
end
```

---

## Troubleshooting

### Problem: "No tenant context set" errors

**Cause:** Trying to query tenant-scoped models without `Current.account` set.

**Solution:**

```ruby
# Set context first
switch_tenant('your-account-slug')

# Or use with_tenant
with_tenant('your-account-slug') do
  # your code here
end
```

### Problem: Queries return empty results

**Cause:** Wrong account context set.

**Solution:**

```ruby
# Check current context
show_tenant

# Switch to correct account
switch_tenant('correct-slug')
```

### Problem: Cannot create records

**Cause:** Models with `TenantScoped` require `Current.account` to auto-assign `account_id`.

**Solution:**

```ruby
# Ensure account is set
switch_tenant('your-account')

# Or create with explicit account
Project.create!(account: account, name: 'Test')
```

### Problem: Seeing data from all tenants

**Cause:** Using `unscoped` or operating `without_tenant`.

**Solution:**

```ruby
# Remove unscoped calls
Project.all  # Scoped to Current.account

# Only use unscoped for admin operations
without_tenant do
  Project.unscoped.all  # Intentionally cross-tenant
end
```

---

## Advanced Usage

### Custom Rake Tasks with Tenant Context

```ruby
# lib/tasks/custom.rake
namespace :data do
  desc "Export data for specific tenant"
  task :export, [:slug] => :environment do |_t, args|
    account = Account.find_by!(slug: args[:slug])
    Current.account = account

    data = {
      account: account.as_json,
      projects: Project.all.as_json,
      teams: Workspace.joins(:teams).distinct.pluck(:name)
    }

    File.write("export_#{args[:slug]}.json", JSON.pretty_generate(data))
    puts "Exported data for #{account.name} to export_#{args[:slug]}.json"
  end
end
```

### Console Scripts

Save commonly used console scripts in `lib/console_scripts/`:

```ruby
# lib/console_scripts/tenant_stats.rb
def tenant_stats(slug)
  with_tenant(slug) do
    {
      account: Current.account.name,
      workspaces: Workspace.count,
      teams: Team.count,
      users: Current.account.users.count,
      projects: Project.count,
      storage_mb: calculate_storage_usage
    }
  end
end

# Load in console
load Rails.root.join('lib/console_scripts/tenant_stats.rb')
tenant_stats('acme-corp')
```

---

## Summary

The tenant management tools provide:

- **Console helpers** for interactive development
- **Rake tasks** for automation and scripting
- **Context management** with automatic restoration
- **Safety** through explicit tenant scoping

Remember:
- Always verify tenant context with `show_tenant`
- Use `with_tenant` for temporary context switches
- Use `without_tenant` carefully for cross-tenant operations
- Document tenant requirements in custom code

For more information, see:
- `/docs/rails_conventions.md` - Multi-tenant patterns
- `/app/models/concerns/tenant_scoped.rb` - Auto-scoping implementation
- `/app/models/current.rb` - Current context attributes
