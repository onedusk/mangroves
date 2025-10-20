# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :set_current_attributes
  end

  private

  def set_current_attributes
    Current.user = current_user if user_signed_in?
  end

  def require_account!
    return if Current.account

    redirect_to new_account_path, alert: "Please create or select an account first."
  end

  def require_workspace!
    return if Current.workspace

    redirect_to account_workspaces_path(Current.account),
      alert: "Please select a workspace first."
  end

  def authorize_account_access!(role: :member)
    membership = current_user.account_memberships.active
      .find_by(account: Current.account)

    return if membership && authorized_role?(membership.role, role)

    redirect_to root_path, alert: "You don't have access to this account."
  end

  def authorize_workspace_access!(role: :member)
    membership = current_user.workspace_memberships.active
      .find_by(workspace: Current.workspace)

    return if membership && authorized_role?(membership.role, role)

    redirect_to root_path, alert: "You don't have access to this workspace."
  end

  def authorized_role?(user_role, required_role)
    role_hierarchy = %w[viewer member admin owner]
    role_hierarchy.index(user_role.to_s) >= role_hierarchy.index(required_role.to_s)
  end
end
