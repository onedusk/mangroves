# frozen_string_literal: true

class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    # NOTE: accounts(slug) already has unique index from schema
    # No need to add duplicate index

    # Add composite index for workspace lookups by account and slug
    # This index already exists as unique, but we verify it's optimal
    # index_workspaces_on_account_id_and_slug already exists

    # Add index for membership queries (user_id, account_id) on account_memberships
    # WARNING: This is for common queries like "find all account memberships for a user"
    # The existing unique index on [account_id, user_id] doesn't optimize user_id lookups
    add_index :account_memberships,
      [:user_id, :account_id],
      name: "index_account_memberships_on_user_id_and_account_id",
      if_not_exists: true

    # Add index for workspace_memberships (user_id, workspace_id) lookups
    # This optimizes queries when finding workspaces for a user
    # The existing unique index on [workspace_id, user_id] doesn't optimize user_id first queries
    add_index :workspace_memberships,
      [:user_id, :workspace_id],
      name: "index_workspace_memberships_on_user_id_and_workspace_id",
      if_not_exists: true

    # Add index for team_memberships (user_id, team_id) lookups
    add_index :team_memberships,
      [:user_id, :team_id],
      name: "index_team_memberships_on_user_id_and_team_id",
      if_not_exists: true
  end
end
