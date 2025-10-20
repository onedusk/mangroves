# frozen_string_literal: true

Rails.logger.info "Seeding database..."

# Create a super admin user
super_admin = User.create!(
  email: "admin@example.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Super",
  last_name: "Admin",
  role: :super_admin,
  status: :active,
  confirmed_at: Time.current
)

# Create primary account
primary_account = Account.create!(
  name: "Acme Corporation",
  slug: "acme-corp",
  plan: :professional,
  status: :active,
  owner: super_admin,
  billing_email: "billing@acme.com"
)

# Add super admin to primary account
AccountMembership.create!(
  account: primary_account,
  user: super_admin,
  role: :owner,
  status: :active,
  accepted_at: Time.current
)

# Create workspaces
dev_workspace = Workspace.create!(
  account: primary_account,
  name: "Development",
  slug: "development",
  description: "Development environment workspace",
  status: :active
)

prod_workspace = Workspace.create!(
  account: primary_account,
  name: "Production",
  slug: "production",
  description: "Production environment workspace",
  status: :active
)

# Add super admin to workspaces
WorkspaceMembership.create!(
  workspace: dev_workspace,
  user: super_admin,
  role: :owner,
  status: :active,
  accepted_at: Time.current
)

WorkspaceMembership.create!(
  workspace: prod_workspace,
  user: super_admin,
  role: :owner,
  status: :active,
  accepted_at: Time.current
)

# Set current workspace for super admin
super_admin.update!(current_workspace: dev_workspace)

# Create teams in development workspace
backend_team = Team.create!(
  workspace: dev_workspace,
  name: "Backend Team",
  slug: "backend",
  description: "Backend development team",
  status: :active
)

frontend_team = Team.create!(
  workspace: dev_workspace,
  name: "Frontend Team",
  slug: "frontend",
  description: "Frontend development team",
  status: :active
)

# Create additional users
3.times do |i|
  user = User.create!(
    email: "developer#{i + 1}@example.com",
    password: "password123",
    password_confirmation: "password123",
    first_name: "Developer",
    last_name: (i + 1).to_s,
    role: :member,
    status: :active,
    confirmed_at: Time.current
  )

  # Add to account
  AccountMembership.create!(
    account: primary_account,
    user:,
    role: i.zero? ? :admin : :member,
    status: :active,
    accepted_at: Time.current,
    invited_by: super_admin
  )

  # Add to dev workspace
  WorkspaceMembership.create!(
    workspace: dev_workspace,
    user:,
    role: i.zero? ? :admin : :member,
    status: :active,
    accepted_at: Time.current,
    invited_by: super_admin
  )

  # Add to teams
  team = i.even? ? backend_team : frontend_team
  TeamMembership.create!(
    team:,
    user:,
    role: i.zero? ? :lead : :member,
    status: :active,
    accepted_at: Time.current,
    invited_by: super_admin
  )

  # Set current workspace
  user.update!(current_workspace: dev_workspace)
end

# Create a secondary account with limited access
secondary_account = Account.create!(
  name: "StartUp Inc",
  slug: "startup-inc",
  plan: :starter,
  status: :active
)

startup_user = User.create!(
  email: "startup@example.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Startup",
  last_name: "Founder",
  role: :member,
  status: :active,
  confirmed_at: Time.current
)

AccountMembership.create!(
  account: secondary_account,
  user: startup_user,
  role: :owner,
  status: :active,
  accepted_at: Time.current
)

secondary_account.update!(owner: startup_user)

workspace = Workspace.create!(
  account: secondary_account,
  name: "Main Workspace",
  slug: "main",
  description: "Main workspace for StartUp Inc",
  status: :active
)

WorkspaceMembership.create!(
  workspace:,
  user: startup_user,
  role: :owner,
  status: :active,
  accepted_at: Time.current
)

startup_user.update!(current_workspace: workspace)

Rails.logger.info "Seeding complete!"
Rails.logger.info "Super Admin: admin@example.com / password123"
Rails.logger.info "Startup User: startup@example.com / password123"
Rails.logger.info "Developers: developer1-3@example.com / password123"
