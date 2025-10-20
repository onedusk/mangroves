# frozen_string_literal: true

class CreateWorkspaces < ActiveRecord::Migration[8.0]
  def change
    create_table :workspaces, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :status, default: 0, null: false
      t.jsonb :settings, default: {}
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    add_index :workspaces, :slug, unique: true
    add_index :workspaces, [:account_id, :slug], unique: true
    add_index :workspaces, :status
  end
end
