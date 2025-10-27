# frozen_string_literal: true

# == Schema Information
#
# Table name: workspace_memberships
#
#  id            :uuid             not null, primary key
#  accepted_at   :datetime
#  invited_at    :datetime
#  metadata      :jsonb
#  role          :integer          default("viewer"), not null
#  status        :integer          default("pending"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invited_by_id :uuid
#  user_id       :uuid             not null
#  workspace_id  :uuid             not null
#
# Indexes
#
#  index_workspace_memberships_on_invited_by_id             (invited_by_id)
#  index_workspace_memberships_on_role                      (role)
#  index_workspace_memberships_on_status                    (status)
#  index_workspace_memberships_on_user_id                   (user_id)
#  index_workspace_memberships_on_user_id_and_workspace_id  (user_id,workspace_id)
#  index_workspace_memberships_on_workspace_id              (workspace_id)
#  index_workspace_memberships_on_workspace_id_and_user_id  (workspace_id,user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
require "rails_helper"

RSpec.describe WorkspaceMembership, type: :model do
  let(:account) { create(:account) }
  let(:workspace) { create(:workspace, account:) }
  let(:user) { create(:user) }

  before do
    create(:account_membership, account:, user:, status: :active, accepted_at: Time.current)
  end

  it "allows membership when the user belongs to the workspace account" do
    membership = described_class.new(workspace:, user:)

    expect(membership).to be_valid
  end

  it "rejects membership when the user belongs to a different account" do
    other_account = create(:account)
    other_user = create(:user)
    create(:account_membership, account: other_account, user: other_user, status: :active, accepted_at: Time.current)

    membership = described_class.new(workspace:, user: other_user)

    expect(membership).not_to be_valid
    expect(membership.errors[:user]).to include("must belong to the workspace's account")
  end
end
