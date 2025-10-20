# frozen_string_literal: true

class WorkspacesController < ApplicationController
  before_action :set_account
  before_action :require_account!
  before_action :authorize_account_access!, only: [:index, :new, :create]
  before_action :set_workspace, only: [:show, :edit, :update, :destroy, :switch]

  def index
    @workspaces = @account.workspaces.active
    authorize Workspace
  end

  def show
    authorize @workspace
  end

  def new
    @workspace = @account.workspaces.new
    authorize @workspace
  end

  def edit
    authorize @workspace
  end

  def create
    @workspace = @account.workspaces.new(workspace_params)
    authorize @workspace

    if @workspace.save
      # Create owner membership for current user
      @workspace.workspace_memberships.create!(user: current_user, role: :owner, status: :active)
      redirect_to [@account, @workspace], notice: "Workspace was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @workspace

    if @workspace.update(workspace_params)
      redirect_to [@account, @workspace], notice: "Workspace was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @workspace
    @workspace.destroy!
    redirect_to account_workspaces_path(@account), notice: "Workspace was successfully deleted."
  end

  def switch
    authorize @workspace, :show?

    # Verify user has membership (this should be caught by Pundit, but double-check)
    membership = current_user.workspace_memberships.active
      .find_by(workspace: @workspace)

    if membership
      previous_workspace = current_user.current_workspace
      current_user.update!(current_workspace: @workspace)
      session[:current_workspace_id] = @workspace.id

      # Log the workspace switch
      AuditEvent.log(
        action: AuditEvent::ACTION_WORKSPACE_SWITCH,
        auditable: @workspace,
        metadata: {
          previous_workspace_id: previous_workspace&.id,
          new_workspace_id: @workspace.id
        }
      )

      redirect_to account_workspace_path(@workspace.account, @workspace),
        notice: "Switched to #{@workspace.name}"
    else
      redirect_to root_path, alert: "You don't have access to this workspace"
    end
  end

  private

  def set_account
    @account = Account.find_by!(slug: params[:account_id])
    Current.account = @account
  end

  def set_workspace
    @workspace = @account.workspaces.find_by!(slug: params[:id])
  end

  def workspace_params
    params.expect(workspace: [:name, :slug, :description])
  end
end
