# frozen_string_literal: true

module TenantScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :account

    # SECURITY: Return empty result set when Current.account is nil to prevent data leaks
    # Never return all records when tenant context is missing
    default_scope lambda {
      if Current.account
        where(account: Current.account)
      else
        where("1=0")  # Returns no records when tenant context missing
      end
    }

    # NOTE: prepend: true ensures this runs before other before_validation callbacks
    # This prevents NoMethodError when other callbacks (like generate_slug) access account
    before_validation :set_current_account, on: :create, prepend: true
    validate :require_current_account_on_create, on: :create

    # SECURITY: Explicit account presence validation
    validates :account, presence: true

    private

    def set_current_account
      self.account ||= Current.account if Current.account
    end

    def require_current_account_on_create
      if Current.account.nil? && account.nil?
        errors.add(:account, "must be set via Current.account for new records")
      end
    end
  end

  class_methods do
    def unscoped_all
      unscoped
    end
  end
end
