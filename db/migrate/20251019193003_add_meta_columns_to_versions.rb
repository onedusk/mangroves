# frozen_string_literal: true

class AddMetaColumnsToVersions < ActiveRecord::Migration[8.0]
  def change
    add_column :versions, :account_id, :uuid
    add_column :versions, :workspace_id, :uuid

    add_index :versions, :account_id
    add_index :versions, :workspace_id
  end
end
