# frozen_string_literal: true

class AddAccountToTeams < ActiveRecord::Migration[8.0]
  def up
    add_reference :teams, :account, null: true, foreign_key: true, type: :uuid

    execute <<~SQL.squish
      UPDATE teams
      SET account_id = workspaces.account_id
      FROM workspaces
      WHERE teams.workspace_id = workspaces.id
    SQL

    change_column_null :teams, :account_id, false
    add_index :teams, [:account_id, :slug], unique: true
  end

  def down
    remove_index :teams, [:account_id, :slug]
    remove_reference :teams, :account, foreign_key: true
  end
end
