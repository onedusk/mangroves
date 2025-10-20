# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  protected

  # Helper to check if user role meets minimum requirement
  # Assumes membership has role enum with values: viewer(0), member(1), admin(2), owner(3)
  def role_at_least?(membership, minimum_role)
    return false unless membership

    membership_roles = membership.class.roles
    membership_roles[membership.role] >= membership_roles[minimum_role.to_s]
  end

  # Helper methods for checking role levels
  def viewer_or_higher?(membership)
    return false unless membership

    true # Any role includes viewer
  end

  def member_or_higher?(membership)
    role_at_least?(membership, :member)
  end

  def admin_or_higher?(membership)
    role_at_least?(membership, :admin)
  end

  def owner?(membership)
    return false unless membership

    membership.owner?
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
