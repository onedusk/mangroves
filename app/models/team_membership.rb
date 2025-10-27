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
class TeamMembership < ApplicationRecord
  belongs_to :team
  belongs_to :user
  belongs_to :invited_by, class_name: "User", optional: true

  enum :role, {member: 0, lead: 1}
  enum :status, {pending: 0, active: 1, suspended: 2, declined: 3}

  validates :user_id, uniqueness: {scope: :team_id}

  before_validation :set_defaults, on: :create

  scope :active, -> { where(status: :active) }
  scope :pending, -> { where(status: :pending) }
  scope :leads, -> { where(role: :lead) }

  delegate :workspace, :account, to: :team
  validate :user_belongs_to_team_workspace, if: -> { user && team }

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

  def user_belongs_to_team_workspace
    return if user.workspace_memberships.exists?(workspace:)

    errors.add(:user, "must belong to the team's workspace")
  end
end
