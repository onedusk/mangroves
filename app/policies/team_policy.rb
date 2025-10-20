# frozen_string_literal: true

class TeamPolicy < ApplicationPolicy
  # User must be member+ of workspace to list teams
  def index?
    member_or_higher?(workspace_membership)
  end

  # User must have team membership to view
  def show?
    team_membership.present?
  end

  # User must be member+ of workspace to create teams
  def create?
    member_or_higher?(workspace_membership)
  end

  # User must be lead of team to update (TeamMembership only has member/lead roles)
  def update?
    team_lead?(team_membership)
  end

  # User must be lead of team to destroy
  def destroy?
    team_lead?(team_membership)
  end

  private

  def workspace_membership
    return @workspace_membership if defined?(@workspace_membership)

    @workspace_membership = user.workspace_memberships.find_by(workspace: record.workspace)
  end

  def team_membership
    return @team_membership if defined?(@team_membership)

    @team_membership = user.team_memberships.find_by(team: record)
  end

  # TeamMembership uses different role enum: member(0), lead(1)
  # Lead is equivalent to admin/owner for teams
  def team_lead?(membership)
    return false unless membership

    membership.lead?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      # Users can only see teams they have membership in
      scope.joins(:team_memberships).where(team_memberships: {user_id: user.id})
    end
  end
end
