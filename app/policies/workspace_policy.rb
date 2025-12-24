# frozen_string_literal: true

class WorkspacePolicy < ApplicationPolicy
  # User must be member+ of account to list workspaces
  def index?
    member_or_higher?(account_membership)
  end

  # User must have workspace membership to view
  def show?
    workspace_membership.present?
  end

  # User must be member+ of account to create workspaces
  def create?
    member_or_higher?(account_membership)
  end

  # User must be admin+ of workspace to update
  def update?
    admin_or_higher?(workspace_membership)
  end

  # User must be owner of workspace to destroy
  def destroy?
    owner?(workspace_membership)
  end

  private

  def account_membership
    return @account_membership if defined?(@account_membership)

    # For class-level authorization (index), use Current.account
    account = record.is_a?(Class) ? Current.account : record.account
    # Use unscoped to bypass TenantScoped concern in tests and policy checks
    @account_membership = AccountMembership.unscoped.find_by(user: user, account: account)
  end

  def workspace_membership
    return @workspace_membership if defined?(@workspace_membership)

    @workspace_membership = user.workspace_memberships.find_by(workspace: record)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      # Users can only see workspaces they have membership in
      # Use unscoped to bypass TenantScoped concern in tests and policy scope
      scope.unscoped.joins(:workspace_memberships).where(workspace_memberships: {user_id: user.id})
    end
  end
end
