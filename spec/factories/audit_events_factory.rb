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
FactoryBot.define do
  factory :audit_event do
    action { "test.action" }
    metadata { {} }

    trait :account_switch do
      action { AuditEvent::ACTION_ACCOUNT_SWITCH }
      account
      auditable factory: %i[account]
    end

    trait :workspace_switch do
      action { AuditEvent::ACTION_WORKSPACE_SWITCH }
      workspace
      auditable factory: %i[workspace]
    end
  end
end
