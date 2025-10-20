# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rails 8.0 application implementing a multi-tenant SaaS platform with Account/Workspace/Team hierarchy. Uses PostgreSQL for primary database, Devise for authentication, Phlex for components, and Tailwind CSS for styling. Configured with Solid Queue, Solid Cache, and Solid Cable for background jobs, caching, and real-time features.

## Development Commands

### Initial Setup

```bash
bin/setup                    # Install dependencies and prepare database
bin/setup --reset            # Drop database and start fresh
```

### Running the Application

```bash
bin/dev                      # Start server with Tailwind watch
bin/rails server             # Start server only (port 3000)
bin/rails console            # Interactive Rails console
```

### Testing

```bash
bin/rake                     # Run all tests and lint checks
bin/rake -m                  # Run checks in parallel (faster, interleaved output)
bundle exec rspec            # Run all RSpec tests
bundle exec rspec spec/path/to/spec.rb           # Run specific test file
bundle exec rspec spec/path/to/spec.rb:42        # Run test at specific line
```

### Linting and Code Quality

```bash
bin/rake                     # Run all checks: spec, erb_lint, rubocop
bin/rake fix                 # Auto-fix linting issues (review changes after)
bundle exec rubocop          # Run Rubocop only
bundle exec rubocop -a       # Auto-correct Rubocop issues
bundle exec erb_lint         # Run ERB linting only
```

### Database

```bash
bin/rails db:migrate         # Run pending migrations
bin/rails db:rollback        # Rollback last migration
bin/rails db:seed            # Seed database
bin/rails db:reset           # Drop, create, migrate, and seed
```

## Architecture

### Multi-Tenant Hierarchy

Three-level tenant hierarchy:
- Account (top-level organization, has billing/subscription)
- Workspace (project/environment within account)
- Team (collaboration group within workspace)

Users have many-to-many relationships with each level through membership tables:
- AccountMembership (role: viewer/member/admin/owner)
- WorkspaceMembership (role: viewer/member/admin/owner)
- TeamMembership (role: viewer/member/admin/owner)

### Request-Scoped Tenancy Pattern

Uses `Current` (ActiveSupport::CurrentAttributes) to maintain tenant context throughout request:

```ruby
# app/models/current.rb
Current.user       # Current user for request
Current.account    # Current account (derived from user.current_workspace.account)
Current.workspace  # Current workspace (stored on user)
```

Set via `Authentication` concern in controllers:
```ruby
before_action :authenticate_user!      # Devise
before_action :set_current_attributes  # Sets Current.user
```

### Automatic Data Scoping

Models that belong to an account use `TenantScoped` concern:

```ruby
# app/models/concerns/tenant_scoped.rb
include TenantScoped
```

This provides:
- Automatic `belongs_to :account` association
- Default scope to Current.account (queries only see tenant's data)
- Auto-assignment of Current.account on create
- `unscoped_all` class method to bypass scoping when needed

### Authorization Pattern

`Authentication` concern provides helper methods:
- `require_account!` - Redirect if no account selected
- `require_workspace!` - Redirect if no workspace selected
- `authorize_account_access!(role: :member)` - Check account access with role
- `authorize_workspace_access!(role: :member)` - Check workspace access with role

Role hierarchy: viewer < member < admin < owner

### Component Architecture

Uses Phlex for Ruby-based components:

```ruby
# app/components/button_component.rb
class ButtonComponent < Phlex::HTML
  def initialize(text, variant: :default, size: :md)
    # Component initialization
  end

  def template
    # HTML rendering using Phlex DSL
  end
end
```

Components use:
- Tailwind CSS for styling
- Stimulus controllers for interactivity (in app/javascript/controllers/)
- No separate template files (HTML in Ruby)

### Testing Stack

- RSpec for test framework
- FactoryBot for test data (suffix: "factory", e.g., users_factory.rb)
- Capybara + Selenium for system tests
- Shoulda Matchers for model validation tests
- VCR + WebMock for HTTP mocking
- Letter Opener for email preview in development

Configuration:
- spec/support/ contains shared test setup
- Generators disabled for: routes, views, javascripts, stylesheets

## Code Style

### Ruby Style

- String literals: double quotes enforced
- No hash braces spaces: `{key: value}` not `{ key: value }`
- Method arguments: fixed indentation
- Rubocop plugins: rails, performance, capybara, factory_bot

### ERB Linting

- Enabled: ErbSafety and Rubocop linters
- Inherits from .rubocop.yml
- Auto-fix available via `erb_lint:autocorrect`

## Key Dependencies

- **Rails**: 8.0.3
- **Database**: PostgreSQL (pg gem)
- **Authentication**: Devise with JWT support (devise, devise-jwt, devise-i18n)
- **Authorization**: Pundit
- **Components**: Phlex, View Component
- **Frontend**: Stimulus, Turbo, Tailwind CSS, Importmap
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **WebSockets**: Solid Cable
- **Deployment**: Kamal, Thruster
- **Vector Search**: pgvector, neighbor
- **AI/MCP**: mcp gem, fast-mcp-annotations
- **Email**: Resend

## Database Schema

Primary key strategy: UUID (via pgcrypto extension)

Key tables:
- accounts (billing entity with plan/subscription)
- workspaces (projects within accounts)
- teams (collaboration groups)
- users (Devise authentication)
- {account,workspace,team}_memberships (join tables with roles)

Models use annotaterb for schema annotations in comments.
