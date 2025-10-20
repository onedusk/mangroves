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
require "rails_helper"

RSpec.describe AuditEvent, type: :model do
  let(:user) { create(:user) }
  let(:account) { create(:account) }
  let(:workspace) { create(:workspace, account: account) }

  describe "associations" do
    it { should belong_to(:auditable).optional }
    it { should belong_to(:user).optional }
    it { should belong_to(:account).optional }
    it { should belong_to(:workspace).optional }
  end

  describe "validations" do
    it { should validate_presence_of(:action) }
  end

  describe ".log" do
    before do
      Current.user = user
      Current.account = account
      Current.workspace = workspace
    end

    after do
      Current.reset
    end

    it "creates audit event with current context" do
      event = AuditEvent.log(
        action: AuditEvent::ACTION_ACCOUNT_SWITCH,
        auditable: account,
        metadata: {test: "data"}
      )

      expect(event).to be_persisted
      expect(event.user).to eq(user)
      expect(event.account).to eq(account)
      expect(event.workspace).to eq(workspace)
      expect(event.metadata["test"]).to eq("data")
    end

    it "works without auditable" do
      event = AuditEvent.log(action: "custom.action")
      expect(event).to be_persisted
      expect(event.action).to eq("custom.action")
    end

    it "stores metadata" do
      event = AuditEvent.log(
        action: "test",
        metadata: {key: "value", nested: {data: true}}
      )

      expect(event.metadata["key"]).to eq("value")
      expect(event.metadata["nested"]["data"]).to eq(true)
    end
  end

  describe "scopes" do
    let!(:event1) { create(:audit_event, account: account, action: "test.one", user: user) }
    let!(:event2) { create(:audit_event, account: account, action: "test.two") }
    let!(:event3) { create(:audit_event, user: user, action: "other.action") }

    it "filters by account" do
      expect(AuditEvent.for_account(account)).to contain_exactly(event1, event2)
    end

    it "filters by user" do
      expect(AuditEvent.for_user(user)).to contain_exactly(event1, event3)
    end

    it "filters by action" do
      expect(AuditEvent.by_action("test.one")).to contain_exactly(event1)
    end

    it "orders by recent" do
      expect(AuditEvent.recent.first).to eq(event3)
    end
  end

  describe "action constants" do
    it "defines standard action types" do
      expect(AuditEvent::ACTION_ACCOUNT_SWITCH).to eq("account.switch")
      expect(AuditEvent::ACTION_WORKSPACE_SWITCH).to eq("workspace.switch")
      expect(AuditEvent::ACTION_USER_LOGIN).to eq("user.login")
      expect(AuditEvent::ACTION_USER_LOGOUT).to eq("user.logout")
      expect(AuditEvent::ACTION_PERMISSION_CHANGE).to eq("permission.change")
    end
  end
end
