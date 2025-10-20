# frozen_string_literal: true

namespace :tenant do
  desc "List all accounts with slug, name, and status"
  task list: :environment do
    accounts = Account.order(:created_at)

    if accounts.empty?
      puts "No accounts found."
      exit
    end

    puts "\nAccounts:"
    puts "-" * 80
    printf "%-30s %-30s %-10s\n", "SLUG", "NAME", "STATUS"
    puts "-" * 80

    accounts.each do |account|
      printf "%-30s %-30s %-10s\n",
        account.slug,
        account.name.truncate(28),
        account.status
    end

    puts "-" * 80
    puts "Total: #{accounts.count} accounts\n\n"
  end

  desc "Switch to account by slug (usage: rake tenant:switch[account-slug])"
  task :switch, [:slug] => :environment do |_t, args|
    unless args[:slug]
      puts "Error: Account slug required"
      puts "Usage: rake tenant:switch[account-slug]"
      exit 1
    end

    account = Account.find_by(slug: args[:slug])

    unless account
      puts "Error: Account '#{args[:slug]}' not found"
      puts "\nAvailable accounts:"
      Account.pluck(:slug).each { |slug| puts "  - #{slug}" }
      exit 1
    end

    Current.account = account
    puts "Switched to account: #{account.name} (#{account.slug})"
    puts "  Status: #{account.status}"
    puts "  Workspaces: #{account.workspaces.count}"
    puts "  Users: #{account.users.count}"

    puts "\nNote: This sets Current.account for this rake task only."
    puts "For console persistence, use: switch_tenant('#{account.slug}')"
  end

  desc "Create a new account with default workspace (usage: rake tenant:create[name])"
  task :create, [:name] => :environment do |_t, args|
    unless args[:name]
      puts "Error: Account name required"
      puts "Usage: rake tenant:create['Account Name']"
      exit 1
    end

    account = nil
    workspace = nil

    Account.transaction do
      account = Account.create!(
        name: args[:name],
        status: :active,
        plan: :free
      )

      # Set Current.account so TenantScoped concern works properly
      Current.account = account

      # Create workspace with account-specific name to avoid slug collisions
      workspace = account.workspaces.create!(
        name: "#{account.name} Workspace",
        status: :active
      )
    end

    puts "Created account: #{account.name}"
    puts "  Slug: #{account.slug}"
    puts "  ID: #{account.id}"
    puts "  Workspace: #{workspace.name} (#{workspace.slug})"
    puts "\nNext steps:"
    puts "  1. Switch context: rake tenant:switch[#{account.slug}]"
  rescue ActiveRecord::RecordInvalid => e
    puts "Error creating account: #{e.message}"
    exit 1
  end

  desc "Show current tenant context"
  task info: :environment do
    if Current.account
      puts "Current Account: #{Current.account.name} (#{Current.account.slug})"
      puts "  ID: #{Current.account.id}"
      puts "  Status: #{Current.account.status}"
      puts "  Plan: #{Current.account.plan}"
    else
      puts "No tenant context set (Current.account is nil)"
    end

    if Current.workspace
      puts "\nCurrent Workspace: #{Current.workspace.name} (#{Current.workspace.slug})"
      puts "  ID: #{Current.workspace.id}"
      puts "  Account: #{Current.workspace.account.name}"
    else
      puts "\nNo workspace context set (Current.workspace is nil)"
    end

    if Current.user
      puts "\nCurrent User: #{Current.user.email}"
      puts "  Name: #{Current.user.full_name}"
    else
      puts "\nNo user context set (Current.user is nil)"
    end
  end

  desc "Reset all tenant context (clear Current.*)"
  task reset: :environment do
    Current.reset
    puts "Tenant context reset"
    puts "  Current.account = nil"
    puts "  Current.workspace = nil"
    puts "  Current.user = nil"
  end
end
