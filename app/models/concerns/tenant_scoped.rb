# frozen_string_literal: true

module TenantScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :account

    default_scope -> { where(account: Current.account) if Current.account }

    before_validation :set_current_account, on: :create

    private

    def set_current_account
      self.account ||= Current.account
    end
  end

  class_methods do
    def unscoped_all
      unscoped
    end
  end
end
