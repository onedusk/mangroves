# frozen_string_literal: true

class CreateTeamMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :team_memberships, id: :uuid do |t|
      t.references :team, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.integer :role, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.uuid :invited_by_id
      t.datetime :invited_at
      t.datetime :accepted_at
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    add_index :team_memberships, [:team_id, :user_id], unique: true
    add_index :team_memberships, :role
    add_index :team_memberships, :status
    add_index :team_memberships, :invited_by_id
  end
end
