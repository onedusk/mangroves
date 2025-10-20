# frozen_string_literal: true

# Console helpers for tenant context management
module ConsoleHelpers
  # Execute block with specific tenant context
  def with_tenant(account_identifier)
    account = case account_identifier
              when Account
                account_identifier
              when String
                Account.find_by!(slug: account_identifier)
              else
                raise ArgumentError, "Expected Account or slug string"
              end

    previous_account = Current.account
    previous_workspace = Current.workspace

    begin
      Current.account = account
      Current.workspace = account.workspaces.active.first

      puts "Switched to: #{account.name} (#{account.slug})" if block_given?

      result = yield

      puts "Restored previous tenant" if block_given? && previous_account

      result
    ensure
      Current.account = previous_account
      Current.workspace = previous_workspace
    end
  end

  # Execute block without any tenant context
  def without_tenant
    previous_account = Current.account
    previous_workspace = Current.workspace
    previous_user = Current.user

    begin
      Current.reset
      puts "Cleared tenant context" if block_given?

      result = yield

      puts "Restored tenant context" if block_given? && previous_account

      result
    ensure
      Current.account = previous_account
      Current.workspace = previous_workspace
      Current.user = previous_user
    end
  end

  # Switch tenant context (persists for console session)
  def switch_tenant(account_identifier)
    account = case account_identifier
              when Account
                account_identifier
              when String
                Account.find_by!(slug: account_identifier)
              else
                raise ArgumentError, "Expected Account or slug string"
              end

    Current.account = account
    Current.workspace = account.workspaces.active.first

    puts "Switched to: #{account.name} (#{account.slug})"
    puts "  Workspace: #{Current.workspace&.name}"
    puts "  Users: #{account.users.count}"
    puts "  Workspaces: #{account.workspaces.count}"

    account
  end

  # Show current tenant context
  def show_tenant
    if Current.account
      puts "\nCurrent Tenant Context"
      puts "-" * 60
      puts "Account:    #{Current.account.name} (#{Current.account.slug})"
      puts "Status:     #{Current.account.status}"
      puts "Plan:       #{Current.account.plan}"

      if Current.workspace
        puts "\nWorkspace:  #{Current.workspace.name} (#{Current.workspace.slug})"
        puts "Teams:      #{Current.workspace.teams.count}"
      else
        puts "\nWorkspace:  (none)"
      end

      if Current.user
        puts "\nUser:       #{Current.user.email}"
        puts "Name:       #{Current.user.full_name}"
      else
        puts "\nUser:       (none)"
      end
      puts "-" * 60
    else
      puts "\nNo tenant context set"
      puts "   Use: switch_tenant('account-slug')"
      puts "   Or:  with_tenant('account-slug') { ... }"
    end

    {
      account: Current.account,
      workspace: Current.workspace,
      user: Current.user
    }
  end

  # List all available accounts
  def list_tenants
    accounts = Account.order(:created_at)

    puts "\nAvailable Accounts (#{accounts.count})"
    puts "-" * 80
    printf "%-30s %-30s %-12s %-6s\n", "SLUG", "NAME", "STATUS", "USERS"
    puts "-" * 80

    accounts.each do |account|
      current = account == Current.account ? ">" : " "
      printf "%s %-29s %-30s %-12s %-6d\n",
        current,
        account.slug.truncate(28),
        account.name.truncate(29),
        account.status,
        account.users.count
    end

    puts "-" * 80

    accounts
  end

  # Clear all tenant context
  def clear_tenant
    Current.reset
    puts "Tenant context cleared"
    nil
  end
end
