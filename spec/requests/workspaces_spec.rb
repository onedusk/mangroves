# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Workspaces", type: :request do
  let(:user) { create(:user) }
  let(:account) { create(:account) }
  let!(:account_membership) do
    create(:account_membership, user: user, account: account, role: :member, status: :active)
  end
  let(:workspace) { create(:workspace, account: account) }

  before do
    sign_in user
    user.update!(current_workspace: workspace)
  end

  describe "GET /accounts/:account_id/workspaces" do
    it "returns successful response" do
      get account_workspaces_path(account)
      expect(response).to have_http_status(:success)
    end

    context "when user is not account member" do
      let(:other_account) { create(:account) }

      it "denies access" do
        get account_workspaces_path(other_account)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("don't have access")
      end
    end
  end

  describe "GET /accounts/:account_id/workspaces/:id" do
    let!(:workspace_membership) do
      create(:workspace_membership, user: user, workspace: workspace, role: :member, status: :active)
    end

    it "shows workspace details" do
      get account_workspace_path(account, workspace)
      expect(response).to have_http_status(:success)
    end

    context "when user has no workspace membership" do
      before { workspace_membership.destroy }

      it "denies access" do
        get account_workspace_path(account, workspace)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /accounts/:account_id/workspaces/new" do
    it "shows new workspace form" do
      get new_account_workspace_path(account)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /accounts/:account_id/workspaces" do
    let(:valid_params) { {workspace: {name: "Test Workspace"}} }

    it "creates new workspace" do
      expect do
        post account_workspaces_path(account), params: valid_params
      end.to change(account.workspaces, :count).by(1)
    end

    it "creates owner membership for current user" do
      post account_workspaces_path(account), params: valid_params
      new_workspace = Workspace.last
      membership = new_workspace.workspace_memberships.find_by(user: user)
      expect(membership.role).to eq("owner")
    end

    it "redirects to workspace show page" do
      post account_workspaces_path(account), params: valid_params
      new_workspace = Workspace.last
      expect(response).to redirect_to(account_workspace_path(account, new_workspace))
    end
  end

  describe "GET /accounts/:account_id/workspaces/:id/edit" do
    let!(:workspace_membership) do
      create(:workspace_membership, user: user, workspace: workspace, role: :admin, status: :active)
    end

    it "shows edit form" do
      get edit_account_workspace_path(account, workspace)
      expect(response).to have_http_status(:success)
    end

    context "when user is viewer" do
      before { workspace_membership.update!(role: :member) }

      it "denies access" do
        get edit_account_workspace_path(account, workspace)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH /accounts/:account_id/workspaces/:id" do
    let!(:workspace_membership) do
      create(:workspace_membership, user: user, workspace: workspace, role: :admin, status: :active)
    end
    let(:update_params) { {workspace: {name: "Updated Workspace"}} }

    it "updates the workspace" do
      patch account_workspace_path(account, workspace), params: update_params
      expect(workspace.reload.name).to eq("Updated Workspace")
    end
  end

  describe "DELETE /accounts/:account_id/workspaces/:id" do
    let!(:workspace_membership) do
      create(:workspace_membership, user: user, workspace: workspace, role: :owner, status: :active)
    end

    it "deletes the workspace" do
      expect do
        delete account_workspace_path(account, workspace)
      end.to change(account.workspaces, :count).by(-1)
    end

    context "when user is not owner" do
      before { workspace_membership.update!(role: :admin) }

      it "denies access" do
        expect do
          delete account_workspace_path(account, workspace)
        end.not_to change(Workspace, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "cross-tenant workspace access" do
    let(:account_a) { create(:account) }
    let(:account_b) { create(:account) }
    let(:workspace_b) { create(:workspace, account: account_b) }
    let(:user_a) { create(:user) }

    before do
      create(:account_membership, user: user_a, account: account_a, role: :member, status: :active)
      sign_in user_a
    end

    it "User in Account A cannot access Account B workspaces" do
      get account_workspaces_path(account_b)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include("don't have access")
    end

    it "returns 404 when trying to access workspace in different account due to tenant scoping" do
      # TenantScoped concern will scope the query to account_b, but workspace_b won't be found
      # because the slug lookup is scoped to account_b.workspaces, and the TenantScoped default_scope
      # further restricts to Current.account which is account_b
      get account_workspace_path(account_b, workspace_b)
      # This will redirect because user doesn't have workspace membership
      expect(response).to redirect_to(root_path)
    end
  end

  context "when not signed in" do
    before { sign_out user }

    it "redirects to sign in" do
      get account_workspaces_path(account)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
