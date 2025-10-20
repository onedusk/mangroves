# Multi-Tenant Readiness Assessment

**Date**: 2025-10-17
**Application**: Mangroves Rails 8.0
**Assessment Type**: Production Readiness for Multi-Tenant SaaS

---

## Executive Summary

The application has foundational multi-tenant infrastructure in place (models, hierarchy, authentication) but lacks critical implementation of tenant scoping, authorization enforcement, and operational tooling. Approximately **30% implemented** of production-ready multi-tenancy requirements.

**Risk Level**: HIGH - Current implementation allows potential cross-tenant data access.

---

## Current Implementation Status

### What EXISTS ✓

#### Data Models
- Account/Workspace/Team hierarchy with proper foreign keys and UUID primary keys
- Membership models (AccountMembership, WorkspaceMembership, TeamMembership) with roles
- Role hierarchy: viewer < member < admin < owner
- Invitation workflow (invited_at, accepted_at, status tracking)
- Slug-based URLs for accounts and workspaces

#### Infrastructure
- `TenantScoped` concern defined in app/models/concerns/tenant_scoped.rb
- `Current` (ActiveSupport::CurrentAttributes) for request-scoped tenant context
- `Authentication` concern with authorization helpers
- PostgreSQL with pgvector, uuid-ossp, pgcrypto extensions
- Devise authentication with confirmable, lockable, trackable modules

#### Testing Setup
- RSpec, FactoryBot, Capybara configured
- Test factories exist for all models
- VCR + WebMock for HTTP mocking

---

## Critical Gaps (MUST FIX)

### 1. Tenant Scoping Not Applied (CRITICAL)

**Issue**: `TenantScoped` concern exists but is NOT used by any tenant-specific models.

**Current State**:
```ruby
# app/models/workspace.rb - NO TenantScoped
class Workspace < ApplicationRecord
  belongs_to :account
  # Missing: include TenantScoped
end

# app/models/team.rb - NO TenantScoped
class Team < ApplicationRecord
  belongs_to :workspace
  # Missing tenant scoping entirely
  # Should delegate :account to workspace and include TenantScoped
end
```

**Impact**:
- Queries can access data across tenant boundaries
- No automatic filtering by Current.account
- High risk of data leaks

**Required Actions**:
1. Add `include TenantScoped` to Workspace model
2. Add `delegate :account, to: :workspace` and scoping to Team model
3. Add TenantScoped to any future content models (Posts, Documents, Projects, etc.)

**Priority**: CRITICAL - Must fix before production

---

### 2. No Actual Tenant Data Models (CRITICAL)

**Issue**: Only organizational models exist. No content models that tenants would create/own.

**Current State**:
- Have: Account, Workspace, Team, User (organizational)
- Missing: Posts, Documents, Projects, Tasks, Comments, etc. (tenant data)

**Impact**:
- Cannot validate tenant isolation with real use cases
- No demonstration of TenantScoped pattern in practice

**Required Actions**:
1. Create at least one content model (e.g., Project, Document)
2. Apply TenantScoped concern
3. Write tests proving cross-tenant isolation

**Priority**: CRITICAL - Core business functionality

---

### 3. Background Jobs Lose Tenant Context (CRITICAL)

**Issue**: ApplicationJob doesn't preserve Current.account when enqueuing jobs.

**Current State**:
```ruby
# app/jobs/application_job.rb
class ApplicationJob < ActiveJob::Base
  # NO tenant context preservation
end
```

**Impact**:
- Jobs can't access tenant-scoped data correctly
- Jobs may process data for wrong tenant
- Email notifications may expose wrong tenant data

**Required Actions**:
```ruby
class ApplicationJob < ActiveJob::Base
  before_perform do |job|
    account_id = job.arguments.find { |arg| arg.is_a?(Hash) }&.dig(:account_id)
    Current.account = Account.find(account_id) if account_id
  end

  around_perform do |job, block|
    # Clear context after job
    Current.reset
    block.call
  ensure
    Current.reset
  end
end
```

**Priority**: CRITICAL - Data corruption risk

---

### 4. Mailers Lose Tenant Context (HIGH)

**Issue**: ApplicationMailer doesn't include tenant context in emails.

**Current State**:
```ruby
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"
  # NO tenant context
end
```

**Impact**:
- Emails may show wrong branding
- Links may not include tenant context (account slug)
- Cannot customize per-tenant email settings

**Required Actions**:
1. Add default_url_options based on Current.account
2. Add tenant-specific from address
3. Add account context to all mailer calls

**Priority**: HIGH - Before sending production emails

---

### 5. No Authorization Policies (CRITICAL)

**Issue**: Pundit gem in Gemfile but no policies defined.

**Current State**:
- app/policies/ directory doesn't exist
- No systematic authorization checks in controllers
- Authorization helpers exist in Authentication concern but incomplete

**Impact**:
- No consistent authorization enforcement
- Must manually check permissions in every action
- Easy to forget authorization checks

**Required Actions**:
1. Create app/policies/ directory
2. Create ApplicationPolicy with base authorization logic
3. Create policies for Account, Workspace, Team
4. Add `authorize @resource` calls in controllers
5. Add policy tests

**Priority**: CRITICAL - Security requirement

---

### 6. No Tenant Isolation Tests (CRITICAL)

**Issue**: All test files have `pending` examples. No tests verify cross-tenant isolation.

**Current State**:
```ruby
# spec/models/workspace_spec.rb
RSpec.describe Workspace, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
```

**Impact**:
- Cannot prove tenant data is isolated
- No regression protection
- Cannot deploy with confidence

**Required Actions**:
Create tests proving:
1. User in Account A cannot access Workspace in Account B
2. Queries automatically scope to Current.account
3. Creating records auto-assigns Current.account
4. Direct record access bypassing scopes is prevented
5. Jobs maintain tenant context

**Priority**: CRITICAL - Cannot deploy without tests

---

### 7. No CRUD Controllers for Tenant Management (HIGH)

**Issue**: Only HomeController and ComponentsController exist. No controllers for:
- AccountsController
- WorkspacesController
- TeamsController
- Account/Workspace MembershipsController

**Current State**:
```ruby
# config/routes.rb
Rails.application.routes.draw do
  devise_for :members  # Why members? Should be users only
  devise_for :users
  root "home#index"
  # NO tenant resource routes
end
```

**Impact**:
- No way to create/update/delete accounts
- No invitation management UI
- No workspace switching
- Cannot onboard new tenants

**Required Actions**:
1. Create nested routes: accounts/:account_id/workspaces
2. Create AccountsController with authorization
3. Create WorkspacesController scoped to current account
4. Create MembershipsController for invitations
5. Add workspace switcher UI

**Priority**: HIGH - Core functionality

---

### 8. No Tenant Switching Mechanism (HIGH)

**Issue**: User can belong to multiple accounts/workspaces but cannot switch between them.

**Current State**:
- User.current_workspace_id exists (good)
- No controller action to update it
- No UI to switch workspaces
- No session storage for last selected workspace

**Impact**:
- Users locked to one workspace
- Cannot test multi-workspace scenarios
- Poor UX for users in multiple organizations

**Required Actions**:
1. POST /accounts/:id/switch endpoint
2. POST /workspaces/:id/switch endpoint
3. Store selection in session
4. Add UI dropdown/menu for switching
5. Update Current.account/workspace after switch

**Priority**: HIGH - User experience

---

## High Priority Gaps

### 9. No Console Helpers for Development (HIGH)

**Issue**: No rake tasks or console helpers for tenant management during development.

**Required Actions**:
Create lib/tasks/tenant.rake:
```ruby
namespace :tenant do
  desc "Switch to tenant (account slug)"
  task :switch, [:slug] => :environment do |t, args|
    account = Account.find_by!(slug: args[:slug])
    Current.account = account
    puts "Switched to: #{account.name}"
  end

  desc "List all tenants"
  task :list => :environment do
    Account.find_each do |account|
      puts "#{account.slug.ljust(20)} #{account.name}"
    end
  end
end
```

**Priority**: HIGH - Development productivity

---

### 10. Orphaned Member Model (MEDIUM)

**Issue**: Member model exists with Devise but appears unused.

**Current State**:
```ruby
# app/models/member.rb - Basic devise model
# routes.rb - devise_for :members (why?)

# User model already has full authentication
```

**Impact**: Confusion, dead code, potential security holes

**Required Actions**:
1. Determine if Member is needed (team members? different auth?)
2. If not needed: remove model, migration, routes, factories
3. If needed: document purpose and relationship to User

**Priority**: MEDIUM - Technical debt

---

### 11. No Request/Controller Tests (HIGH)

**Issue**: No request specs testing authorization in realistic scenarios.

**Required Actions**:
Create spec/requests/ tests for:
1. User in Account A tries to access Account B resources (should 404/403)
2. Viewer role cannot perform admin actions
3. Suspended user cannot access account
4. Pending invitation cannot access resources
5. Unauthenticated access redirects to login

**Priority**: HIGH - Security validation

---

### 12. No Database Row-Level Security (MEDIUM)

**Issue**: Relying on application-level scoping without database-level protection.

**Risk**: If application code is bypassed (SQL injection, raw queries, console misuse), data is exposed.

**Recommended**: PostgreSQL Row-Level Security (RLS) policies

**Example**:
```sql
-- Enable RLS on workspaces table
ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;

-- Create policy
CREATE POLICY tenant_isolation ON workspaces
  USING (account_id = current_setting('app.current_account_id')::uuid);
```

**Required Actions**:
1. Add RLS policies to tenant-scoped tables
2. Set current_account_id in database session
3. Test RLS prevents cross-tenant access even with unscoped queries

**Priority**: MEDIUM - Defense in depth

---

### 13. No Subdomain/Domain Routing (MEDIUM)

**Issue**: Single domain for all tenants. No subdomain routing (acme.app.com vs beta.app.com).

**Impact**:
- Cannot provide tenant-specific URLs
- Cannot use subdomain for automatic tenant detection
- URL structure: app.com/accounts/acme vs acme.app.com

**Required Actions** (if subdomain routing desired):
1. Add subdomain constraint to routes
2. Add middleware to set Current.account from subdomain
3. Update Account model with subdomain field
4. Configure DNS wildcards
5. Update URL helpers to include subdomain

**Priority**: MEDIUM - Feature requirement (if needed)

---

### 14. No Audit Logging (HIGH)

**Issue**: No tracking of who accessed what data, when.

**Impact**:
- Cannot detect unauthorized access attempts
- No compliance trail (SOC2, GDPR, HIPAA)
- Cannot investigate security incidents

**Required Actions**:
1. Add paper_trail or audited gem
2. Log all tenant switches
3. Log all authorization failures
4. Log all admin actions
5. Create admin dashboard for audit logs

**Priority**: HIGH - Security & compliance

---

## Medium Priority Gaps

### 15. No Rate Limiting per Tenant (MEDIUM)

**Issue**: No rate limiting to prevent abuse by individual tenants.

**Required Actions**:
1. Add Rack::Attack gem
2. Configure per-account rate limits
3. Add throttling for API endpoints
4. Add tenant-specific quotas

**Priority**: MEDIUM - Operational stability

---

### 16. No Billing Enforcement (MEDIUM)

**Issue**: Account.plan and subscription_ends_at fields exist but not enforced.

**Current State**:
```ruby
# app/models/account.rb
enum :plan, {free: "free", starter: "starter", professional: "professional", enterprise: "enterprise"}
# But no enforcement anywhere
```

**Required Actions**:
1. Create subscription enforcement concern
2. Check subscription status in ApplicationController
3. Redirect expired accounts to billing page
4. Implement feature flags per plan (workspace limits, user limits)
5. Add Stripe integration (rbstripe gem in Gemfile but not used)

**Priority**: MEDIUM - Revenue protection

---

### 17. No Onboarding Flow (MEDIUM)

**Issue**: No controllers/views for creating first account after signup.

**Required Actions**:
1. After user signup, redirect to account creation
2. Create default workspace for new account
3. Add user as owner of account
4. Guide through initial setup
5. Set Current.account and current_workspace_id

**Priority**: MEDIUM - User experience

---

### 18. No Admin/Support Interface (LOW)

**Issue**: No super_admin tools to view/manage all tenants.

**Required Actions**:
1. Create Admin namespace
2. Add ability to view all accounts (bypass scoping)
3. Add impersonation feature
4. Add account suspension/activation
5. Protect with super_admin role check

**Priority**: LOW - Support tooling

---

### 19. No Current Context in Views (LOW)

**Issue**: Views need account/workspace context but must call helpers.

**Required Actions**:
Add to ApplicationHelper:
```ruby
def current_account
  Current.account
end

def current_workspace
  Current.workspace
end

def tenant_url_for(path)
  # Include account/workspace in URL
end
```

**Priority**: LOW - Developer experience

---

## Implementation Roadmap

### Phase 1: Critical Security Fixes (Week 1)
1. Apply TenantScoped to Workspace and Team models
2. Write tenant isolation tests (prove scoping works)
3. Fix ApplicationJob tenant context
4. Create basic AccountsController and WorkspacesController
5. Remove or document Member model

### Phase 2: Authorization (Week 2)
1. Create Pundit policies for all models
2. Add authorization checks to controllers
3. Write request specs testing authorization
4. Implement workspace switching

### Phase 3: Operational Essentials (Week 3)
1. Fix ApplicationMailer tenant context
2. Add audit logging
3. Create console helpers and rake tasks
4. Write comprehensive model tests

### Phase 4: Feature Completion (Week 4)
1. Implement onboarding flow
2. Add billing enforcement
3. Create invitation management
4. Build admin interface

### Phase 5: Hardening (Ongoing)
1. Add Row-Level Security policies
2. Implement rate limiting
3. Add subdomain routing (if needed)
4. Performance testing under multi-tenant load

---

## Testing Checklist

Before production deployment, verify:

- [ ] User in Account A cannot see/modify data in Account B
- [ ] All models requiring tenant scoping include TenantScoped
- [ ] Background jobs maintain tenant context
- [ ] Mailers include correct tenant context
- [ ] All controllers have authorization checks
- [ ] Policy tests cover all roles (viewer, member, admin, owner)
- [ ] Request specs cover cross-tenant access attempts
- [ ] Tenant switching updates Current.account correctly
- [ ] Suspended accounts cannot access system
- [ ] Audit log captures all security-relevant events
- [ ] Rate limiting prevents abuse
- [ ] Billing enforcement blocks expired accounts
- [ ] Console operations respect tenant context
- [ ] Raw SQL queries do not bypass tenant scoping

---

## Recommended Architecture Improvements

### 1. Middleware for Tenant Detection

```ruby
# lib/middleware/tenant_loader.rb
class TenantLoader
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)

    # Load from subdomain, path, or header
    account = find_account(request)
    Current.account = account if account

    @app.call(env)
  ensure
    Current.reset
  end

  private

  def find_account(request)
    # Try subdomain first
    if request.subdomain.present?
      Account.find_by(subdomain: request.subdomain)
    # Try path parameter
    elsif request.params[:account_id]
      Account.find_by(id: request.params[:account_id])
    end
  end
end
```

### 2. Tenant Context Module

```ruby
# app/models/concerns/tenant_context.rb
module TenantContext
  extend ActiveSupport::Concern

  def self.with_tenant(account, &block)
    previous_account = Current.account
    Current.account = account
    block.call
  ensure
    Current.account = previous_account
  end

  def self.without_tenant(&block)
    previous_account = Current.account
    Current.account = nil
    block.call
  ensure
    Current.account = previous_account
  end
end
```

### 3. Authorization Concern

```ruby
# app/controllers/concerns/authorization.rb
module Authorization
  extend ActiveSupport::Concern

  included do
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
```

---

## Security Recommendations

1. **Never trust Current.account in isolation** - Always verify user membership
2. **Use Pundit policies** - Don't inline authorization logic
3. **Test cross-tenant access** - Security tests are critical
4. **Audit all tenant switches** - Log who accessed what tenant
5. **Implement RLS** - Database-level protection as failsafe
6. **Monitor for anomalies** - Alert on unusual cross-tenant queries
7. **Regular security audits** - Review tenant isolation quarterly

---

## Conclusion

The application has good foundational architecture for multi-tenancy but requires significant implementation work before production deployment. Critical gaps in tenant scoping, authorization, and testing present security risks.

**Estimated effort to production-ready**: 3-4 weeks (1 developer)

**Risk if deployed as-is**: HIGH - Cross-tenant data access is possible

**Next immediate actions**:
1. Apply TenantScoped to Workspace and Team models
2. Write tenant isolation tests
3. Fix ApplicationJob tenant context
4. Create Account and Workspace controllers with Pundit policies
