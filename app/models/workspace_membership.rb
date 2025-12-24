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
class WorkspaceMembership < ApplicationRecord
  belongs_to :workspace
  belongs_to :user
  belongs_to :invited_by, class_name: "User", optional: true

  enum :role, {viewer: 0, member: 1, admin: 2, owner: 3}
  enum :status, {pending: 0, active: 1, suspended: 2, declined: 3}

  validates :user_id, uniqueness: {scope: :workspace_id}

  before_validation :set_defaults, on: :create

  scope :active, -> { where(status: :active) }
  scope :pending, -> { where(status: :pending) }
  scope :admins, -> { where(role: %i[admin owner]) }

  delegate :account, to: :workspace
  validate :user_belongs_to_workspace_account, if: -> { user && workspace }

  def accept!
    update!(status: :active, accepted_at: Time.current)
  end

  def decline!
    update!(status: :declined)
  end

  private

  def set_defaults
    self.role ||= :member
    self.status ||= :pending
    self.invited_at ||= Time.current
    self.metadata ||= {}
  end

  def user_belongs_to_workspace_account
    workspace_account = workspace.account
    # Use unscoped to bypass TenantScoped concern - we need to check membership
    # across all accounts, not just Current.account
    has_membership = AccountMembership.unscoped.exists?(
      user_id: user.id,
      account_id: workspace_account.id
    )

    return if has_membership

    errors.add(:user, "must belong to the workspace's account")
  end
end
