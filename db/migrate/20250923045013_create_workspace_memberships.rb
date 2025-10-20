# frozen_string_literal: true

class CreateWorkspaceMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :workspace_memberships, id: :uuid do |t|
      t.references :workspace, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.integer :role, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.uuid :invited_by_id
      t.datetime :invited_at
      t.datetime :accepted_at
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    add_index :workspace_memberships, [:workspace_id, :user_id], unique: true
    add_index :workspace_memberships, :role
    add_index :workspace_memberships, :status
    add_index :workspace_memberships, :invited_by_id
  end
end
