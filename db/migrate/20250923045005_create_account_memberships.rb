# frozen_string_literal: true

class CreateAccountMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :account_memberships, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.integer :role, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.uuid :invited_by_id
      t.datetime :invited_at
      t.datetime :accepted_at
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    add_index :account_memberships, [:account_id, :user_id], unique: true
    add_index :account_memberships, :role
    add_index :account_memberships, :status
    add_index :account_memberships, :invited_by_id
  end
end
