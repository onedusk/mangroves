# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :plan, default: "free"
      t.integer :status, default: 0, null: false
      t.uuid :owner_id
      t.string :billing_email
      t.datetime :trial_ends_at
      t.datetime :subscription_ends_at
      t.jsonb :settings, default: {}
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    add_index :accounts, :slug, unique: true
    add_index :accounts, :owner_id
    add_index :accounts, :status
  end
end
