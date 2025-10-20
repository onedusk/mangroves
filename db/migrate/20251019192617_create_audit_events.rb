# frozen_string_literal: true

class CreateAuditEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_events, id: :uuid do |t|
      t.string :action, null: false
      t.string :auditable_type
      t.uuid :auditable_id
      t.uuid :user_id
      t.uuid :account_id
      t.uuid :workspace_id
      t.jsonb :metadata, default: {}
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :audit_events, [:auditable_type, :auditable_id]
    add_index :audit_events, :user_id
    add_index :audit_events, :account_id
    add_index :audit_events, :workspace_id
    add_index :audit_events, :action
    add_index :audit_events, :created_at

    add_foreign_key :audit_events, :users, on_delete: :nullify
    add_foreign_key :audit_events, :accounts, on_delete: :cascade
    add_foreign_key :audit_events, :workspaces, on_delete: :cascade
  end
end
