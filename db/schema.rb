# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_19_193003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"
  enable_extension "uuid-ossp"

  create_table "account_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "user_id", null: false
    t.integer "role", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.uuid "invited_by_id"
    t.datetime "invited_at"
    t.datetime "accepted_at"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "user_id"], name: "index_account_memberships_on_account_id_and_user_id", unique: true
    t.index ["account_id"], name: "index_account_memberships_on_account_id"
    t.index ["invited_by_id"], name: "index_account_memberships_on_invited_by_id"
    t.index ["role"], name: "index_account_memberships_on_role"
    t.index ["status"], name: "index_account_memberships_on_status"
    t.index ["user_id"], name: "index_account_memberships_on_user_id"
  end

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "plan", default: "free"
    t.integer "status", default: 0, null: false
    t.uuid "owner_id"
    t.string "billing_email"
    t.datetime "trial_ends_at"
    t.datetime "subscription_ends_at"
    t.jsonb "settings", default: {}
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_accounts_on_owner_id"
    t.index ["slug"], name: "index_accounts_on_slug", unique: true
    t.index ["status"], name: "index_accounts_on_status"
  end

  create_table "audit_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "action", null: false
    t.string "auditable_type"
    t.uuid "auditable_id"
    t.uuid "user_id"
    t.uuid "account_id"
    t.uuid "workspace_id"
    t.jsonb "metadata", default: {}
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_audit_events_on_account_id"
    t.index ["action"], name: "index_audit_events_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_events_on_auditable_type_and_auditable_id"
    t.index ["created_at"], name: "index_audit_events_on_created_at"
    t.index ["user_id"], name: "index_audit_events_on_user_id"
    t.index ["workspace_id"], name: "index_audit_events_on_workspace_id"
  end

  create_table "team_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "team_id", null: false
    t.uuid "user_id", null: false
    t.integer "role", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.uuid "invited_by_id"
    t.datetime "invited_at"
    t.datetime "accepted_at"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invited_by_id"], name: "index_team_memberships_on_invited_by_id"
    t.index ["role"], name: "index_team_memberships_on_role"
    t.index ["status"], name: "index_team_memberships_on_status"
    t.index ["team_id", "user_id"], name: "index_team_memberships_on_team_id_and_user_id", unique: true
    t.index ["team_id"], name: "index_team_memberships_on_team_id"
    t.index ["user_id"], name: "index_team_memberships_on_user_id"
  end

  create_table "teams", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "workspace_id", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.integer "status", default: 0, null: false
    t.jsonb "settings", default: {}
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "account_id", null: false
    t.index ["account_id", "slug"], name: "index_teams_on_account_id_and_slug", unique: true
    t.index ["account_id"], name: "index_teams_on_account_id"
    t.index ["status"], name: "index_teams_on_status"
    t.index ["workspace_id", "slug"], name: "index_teams_on_workspace_id_and_slug", unique: true
    t.index ["workspace_id"], name: "index_teams_on_workspace_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "avatar_url"
    t.integer "role", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.uuid "current_workspace_id"
    t.jsonb "settings", default: {}
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["current_workspace_id"], name: "index_users_on_current_workspace_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["status"], name: "index_users_on_status"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.string "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.uuid "account_id"
    t.uuid "workspace_id"
    t.index ["account_id"], name: "index_versions_on_account_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["workspace_id"], name: "index_versions_on_workspace_id"
  end

  create_table "workspace_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "workspace_id", null: false
    t.uuid "user_id", null: false
    t.integer "role", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.uuid "invited_by_id"
    t.datetime "invited_at"
    t.datetime "accepted_at"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invited_by_id"], name: "index_workspace_memberships_on_invited_by_id"
    t.index ["role"], name: "index_workspace_memberships_on_role"
    t.index ["status"], name: "index_workspace_memberships_on_status"
    t.index ["user_id"], name: "index_workspace_memberships_on_user_id"
    t.index ["workspace_id", "user_id"], name: "index_workspace_memberships_on_workspace_id_and_user_id", unique: true
    t.index ["workspace_id"], name: "index_workspace_memberships_on_workspace_id"
  end

  create_table "workspaces", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.integer "status", default: 0, null: false
    t.jsonb "settings", default: {}
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "slug"], name: "index_workspaces_on_account_id_and_slug", unique: true
    t.index ["account_id"], name: "index_workspaces_on_account_id"
    t.index ["slug"], name: "index_workspaces_on_slug", unique: true
    t.index ["status"], name: "index_workspaces_on_status"
  end

  add_foreign_key "account_memberships", "accounts"
  add_foreign_key "account_memberships", "users"
  add_foreign_key "audit_events", "accounts", on_delete: :cascade
  add_foreign_key "audit_events", "users", on_delete: :nullify
  add_foreign_key "audit_events", "workspaces", on_delete: :cascade
  add_foreign_key "team_memberships", "teams"
  add_foreign_key "team_memberships", "users"
  add_foreign_key "teams", "accounts"
  add_foreign_key "teams", "workspaces"
  add_foreign_key "workspace_memberships", "users"
  add_foreign_key "workspace_memberships", "workspaces"
  add_foreign_key "workspaces", "accounts"
end
