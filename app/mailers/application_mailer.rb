# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # Tenant Context for Mailers
  #
  # Mailers preserve tenant context for:
  # - URL generation with account parameters (default_url_options)
  # - Tenant-specific from addresses (uses Account#billing_email if present)
  # - Template access to @account instance variable
  #
  # The tenant context flows from:
  # 1. Background Jobs: ApplicationJob's around_perform restores Current.account
  # 2. Controllers: Authentication concern sets Current.user → Current.account
  #
  # Usage Example:
  #   class UserMailer < ApplicationMailer
  #     def welcome(user)
  #       @user = user
  #       # @account is automatically available from before_action
  #       mail(to: user.email, subject: "Welcome to #{@account&.name || 'our app'}")
  #     end
  #   end
  #
  # When calling from jobs (Current.account already set by job):
  #   UserMailer.welcome(user).deliver_later

  default from: -> { default_from_address }
  layout "mailer"

  before_action :set_account

  private

  def set_account
    @account = Current.account
  end

  def default_from_address
    if Current.account&.billing_email.present?
      Current.account.billing_email
    else
      "noreply@example.com"
    end
  end

  def default_url_options
    options = (super || {}).dup

    # Include account_id in URLs if Current.account is set
    # Uses slug for friendly URLs (consistent with controllers)
    if Current.account
      options[:account_id] = Current.account.slug
    end

    options
  end
end
