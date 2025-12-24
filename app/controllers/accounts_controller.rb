# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :switch]

  def index
    @accounts = current_user.accessible_accounts
    authorize Account
  end

  def show
    authorize @account
  end

  def new
    @account = Account.new
    authorize @account
  end

  def edit
    authorize @account
  end

  def create
    @account = Account.new(account_params)
    authorize @account

    if @account.save
      # Create owner membership for current user
      @account.account_memberships.create!(user: current_user, role: :owner, status: :active)
      @account.update!(owner: current_user)

      # SECURITY: Audit log account creation
      AuditEvent.log(
        action: AuditEvent::ACTION_ACCOUNT_CREATE,
        auditable: @account,
        metadata: {
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        }
      )

      redirect_to @account, notice: "Account was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @account

    if @account.update(account_params)
      # SECURITY: Audit log account updates
      AuditEvent.log(
        action: AuditEvent::ACTION_ACCOUNT_UPDATE,
        auditable: @account,
        metadata: {
          ip_address: request.remote_ip,
          user_agent: request.user_agent,
          changes: @account.previous_changes
        }
      )

      redirect_to @account, notice: "Account was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def switch
    authorize @account, :show?

    # Find first accessible workspace in this account
    workspace = current_user.workspaces
      .where(account: @account)
      .active
      .first

    if workspace
      previous_account = Current.account
      current_user.update!(current_workspace: workspace)
      session[:current_workspace_id] = workspace.id

      # Log the account switch
      AuditEvent.log(
        action: AuditEvent::ACTION_ACCOUNT_SWITCH,
        auditable: @account,
        metadata: {
          previous_account_id: previous_account&.id,
          new_account_id: @account.id,
          workspace_id: workspace.id
        }
      )

      redirect_to account_path(@account), notice: "Switched to #{@account.name}"
    else
      redirect_to root_path, alert: "No accessible workspaces in this account"
    end
  end

  private

  def set_account
    @account = Account.find_by!(slug: params[:id])
  end

  def account_params
    params.expect(account: [:name, :slug, :billing_email])
  end
end
