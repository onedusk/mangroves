# frozen_string_literal: true

# Load console helpers in Rails console
Rails.application.console do
  require Rails.root.join("lib/console_helpers")

  include ConsoleHelpers

  puts "\nMangroves Multi-Tenant Console"
  puts "-" * 60
  puts "Tenant helpers loaded:"
  puts "  - switch_tenant('slug')     - Switch to account"
  puts "  - with_tenant('slug') {...} - Execute with context"
  puts "  - without_tenant {...}      - Execute without context"
  puts "  - show_tenant               - Show current context"
  puts "  - list_tenants              - List all accounts"
  puts "  - clear_tenant              - Clear context"
  puts "-" * 60
  puts "Rake tasks available:"
  puts "  - rake tenant:list          - List accounts"
  puts "  - rake tenant:switch[slug]  - Switch context"
  puts "  - rake tenant:create[name]  - Create account"
  puts "  - rake tenant:info          - Show context"
  puts "  - rake tenant:reset         - Reset context"
  puts "-" * 60
  puts ""
end
