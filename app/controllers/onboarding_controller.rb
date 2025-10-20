# frozen_string_literal: true

class OnboardingController < ApplicationController
  skip_before_action :set_current_attributes, only: [:new, :create]

  def new
    # NOTE: This is only for users who just signed up and have no accounts
    redirect_to root_path if current_user.accounts.any?
  end

  def create
    ActiveRecord::Base.transaction do
      account = create_account!
      workspace = create_default_workspace!(account)
      create_owner_membership!(account)
      update_user_workspace!(workspace)

      redirect_to account, notice: "Welcome! Your account has been created successfully."
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "Failed to create account: #{e.record.errors.full_messages.to_sentence}"
    render :new, status: :unprocessable_content
  end

  private

  def create_account!
    Account.create!(account_params.merge(owner: current_user))
  end

  def create_default_workspace!(account)
    account.workspaces.create!(
      name: "Default",
      slug: "default"
    )
  end

  def create_owner_membership!(account)
    AccountMembership.create!(
      account: account,
      user: current_user,
      role: :owner,
      status: :active,
      accepted_at: Time.current
    )
  end

  def update_user_workspace!(workspace)
    current_user.update!(current_workspace_id: workspace.id)
  end

  def account_params
    params.expect(account: [:name])
  end
end
