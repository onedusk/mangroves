# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id           :uuid             not null, primary key
#  description  :text
#  account_id   :uuid             not null
#  metadata     :jsonb
#  name         :string           not null
#  settings     :jsonb
#  slug         :string           not null
#  status       :integer          default("active"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  workspace_id :uuid             not null
#
# Indexes
#
#  index_teams_on_account_id             (account_id)
#  index_teams_on_account_id_and_slug    (account_id,slug) UNIQUE
#  index_teams_on_status                 (status)
#  index_teams_on_workspace_id           (workspace_id)
#  index_teams_on_workspace_id_and_slug  (workspace_id,slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
require "rails_helper"
require "securerandom"

RSpec.describe Team, type: :model do
  around do |example|
    Current.reset
    example.run
    Current.reset
  end

  it "includes TenantScoped" do
    expect(described_class.ancestors).to include(TenantScoped)
  end

  it_behaves_like "tenant scoped model" do
    def build_tenant_record_for(account)
      workspace = create(:workspace, account:)
      described_class.new(workspace:, name: "Team #{SecureRandom.hex(4)}")
    end

    # NOTE: Team has sync_account_from_workspace callback that derives account from workspace
    # This means it doesn't require Current.account since workspace provides it
    # Skip the "raises error when Current.account is missing" test for Team
    def skip_require_current_account_test?
      true
    end
  end

  describe "validations" do
    it "requires the workspace and account to align" do
      workspace_account = create(:account)
      mismatched_account = create(:account)
      workspace = create(:workspace, account: workspace_account)

      Current.account = mismatched_account
      team = described_class.new(workspace:, name: "Support Squad")

      expect(team).not_to be_valid
      expect(team.errors[:account]).to include("must belong to the same account as workspace")
    end
  end
end
