# frozen_string_literal: true

# == Schema Information
#
# Table name: team_memberships
#
#  id            :uuid             not null, primary key
#  accepted_at   :datetime
#  invited_at    :datetime
#  metadata      :jsonb
#  role          :integer          default("member"), not null
#  status        :integer          default("pending"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invited_by_id :uuid
#  team_id       :uuid             not null
#  user_id       :uuid             not null
#
# Indexes
#
#  index_team_memberships_on_invited_by_id        (invited_by_id)
#  index_team_memberships_on_role                 (role)
#  index_team_memberships_on_status               (status)
#  index_team_memberships_on_team_id              (team_id)
#  index_team_memberships_on_team_id_and_user_id  (team_id,user_id) UNIQUE
#  index_team_memberships_on_user_id              (user_id)
#  index_team_memberships_on_user_id_and_team_id  (user_id,team_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe TeamMembership, type: :model do
  let(:account) { create(:account) }
  let(:workspace) { create(:workspace, account:) }
  let(:team) { create(:team, workspace:) }
  let(:user) { create(:user) }

  before do
    create(:account_membership, account:, user:, status: :active, accepted_at: Time.current)
    create(:workspace_membership, workspace:, user:, status: :active, accepted_at: Time.current)
  end

  it "allows membership when the user belongs to the team's workspace" do
    membership = described_class.new(team:, user:)

    expect(membership).to be_valid
  end

  it "rejects membership when the user does not belong to the team's workspace" do
    other_account = create(:account)
    other_workspace = create(:workspace, account: other_account)
    other_user = create(:user)
    create(:account_membership, account: other_account, user: other_user, status: :active, accepted_at: Time.current)
    create(
      :workspace_membership,
      workspace: other_workspace,
      user: other_user,
      status: :active,
      accepted_at: Time.current
    )

    membership = described_class.new(team:, user: other_user)

    expect(membership).not_to be_valid
    expect(membership.errors[:user]).to include("must belong to the team's workspace")
  end
end
