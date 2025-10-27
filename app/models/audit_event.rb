# frozen_string_literal: true

# == Schema Information
#
# Table name: audit_events
#
#  id             :uuid             not null, primary key
#  action         :string           not null
#  auditable_type :string
#  ip_address     :string
#  metadata       :jsonb
#  user_agent     :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  account_id     :uuid
#  auditable_id   :uuid
#  user_id        :uuid
#  workspace_id   :uuid
#
# Indexes
#
#  index_audit_events_on_account_id                       (account_id)
#  index_audit_events_on_action                           (action)
#  index_audit_events_on_auditable_type_and_auditable_id  (auditable_type,auditable_id)
#  index_audit_events_on_created_at                       (created_at)
#  index_audit_events_on_user_id                          (user_id)
#  index_audit_events_on_workspace_id                     (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id) ON DELETE => cascade
#  fk_rails_...  (user_id => users.id) ON DELETE => nullify
#  fk_rails_...  (workspace_id => workspaces.id) ON DELETE => cascade
#
class AuditEvent < ApplicationRecord
  # NOTE: AuditEvent is exempt from TenantScoped because audit events can exist
  # without an account context (e.g., global admin actions, pre-login events).
  # Instead, we implement custom scoping that filters by account when available.

  belongs_to :auditable, polymorphic: true, optional: true
  belongs_to :user, optional: true
  belongs_to :account, optional: true
  belongs_to :workspace, optional: true

  validates :action, presence: true

  # Scopes for filtering
  scope :for_account, ->(account) { where(account_id: account.id) }
  scope :for_user, ->(user) { where(user_id: user.id) }
  scope :by_action, ->(action) { where(action: action) }
  scope :recent, -> { order(created_at: :desc) }

  # Common audit actions
  ACTION_ACCOUNT_SWITCH = "account.switch"
  ACTION_WORKSPACE_SWITCH = "workspace.switch"
  ACTION_USER_LOGIN = "user.login"
  ACTION_USER_LOGOUT = "user.logout"
  ACTION_PERMISSION_CHANGE = "permission.change"
  ACTION_ACCOUNT_CREATE = "account.create"
  ACTION_ACCOUNT_UPDATE = "account.update"
  ACTION_WORKSPACE_CREATE = "workspace.create"
  ACTION_WORKSPACE_UPDATE = "workspace.update"
  ACTION_WORKSPACE_DELETE = "workspace.delete"
  ACTION_TEAM_CREATE = "team.create"
  ACTION_TEAM_UPDATE = "team.update"
  ACTION_TEAM_DELETE = "team.delete"
  ACTION_MEMBERSHIP_CREATE = "membership.create"
  ACTION_MEMBERSHIP_UPDATE = "membership.update"
  ACTION_MEMBERSHIP_DELETE = "membership.delete"

  # Helper to log events with current context
  # @param action [String] The action being logged
  # @param auditable [ActiveRecord::Base, nil] The record being acted upon
  # @param metadata [Hash] Additional metadata (ip_address, user_agent, etc.)
  def self.log(action:, auditable: nil, metadata: {})
    create!(
      action: action,
      auditable: auditable,
      user: Current.user,
      account: Current.account,
      workspace: Current.workspace,
      metadata: metadata,
      ip_address: metadata[:ip_address],
      user_agent: metadata[:user_agent]
    )
  rescue ActiveRecord::RecordInvalid => e
    # SECURITY: Log audit failures but don't raise to avoid blocking operations
    Rails.logger.error("Failed to create audit event: #{e.message}")
  end

  private

  # Override TenantScoped's account requirement validation since audit events
  # can be created without account context (e.g., global admin actions)
  def require_current_account_on_create
    # No-op: Allow audit events to be created without account
  end
end
