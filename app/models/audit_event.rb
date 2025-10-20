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

  # Helper to log events with current context
  def self.log(action:, auditable: nil, metadata: {})
    create!(
      action: action,
      auditable: auditable,
      user: Current.user,
      account: Current.account,
      workspace: Current.workspace,
      metadata: metadata,
      ip_address: metadata[:ip_address]
    )
  end
end
