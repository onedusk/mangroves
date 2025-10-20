# frozen_string_literal: true

class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams, id: :uuid do |t|
      t.references :workspace, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :status, default: 0, null: false
      t.jsonb :settings, default: {}
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    add_index :teams, [:workspace_id, :slug], unique: true
    add_index :teams, :status
  end
end
