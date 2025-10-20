# frozen_string_literal: true

class AccountPolicy < ApplicationPolicy
  # Any authenticated user can list their accounts
  def index?
    user.present?
  end

  # User must have membership to view an account
  def show?
    account_membership.present?
  end

  # Any authenticated user can create accounts
  def create?
    user.present?
  end

  # User must be admin or owner to update
  def update?
    admin_or_higher?(account_membership)
  end

  # Only owner can destroy
  def destroy?
    owner?(account_membership)
  end

  private

  def account_membership
    return @account_membership if defined?(@account_membership)

    @account_membership = user.account_memberships.find_by(account: record)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      # Users can only see accounts they belong to
      scope.joins(:account_memberships).where(account_memberships: {user_id: user.id})
    end
  end
end
