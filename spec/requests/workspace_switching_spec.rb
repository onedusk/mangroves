# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Workspace Switching", type: :request do
  let(:user) { create(:user) }
  let(:account) { create(:account) }
  let(:workspace1) { create(:workspace, account: account, name: "Workspace 1") }
  let(:workspace2) { create(:workspace, account: account, name: "Workspace 2") }

  before do
    create(:account_membership, user: user, account: account, role: :member, status: :active)
    create(:workspace_membership, user: user, workspace: workspace1, role: :member, status: :active)
    create(:workspace_membership, user: user, workspace: workspace2, role: :member, status: :active)
    sign_in user
  end

  describe "POST /accounts/:id/switch" do
    it "switches to the account's first accessible workspace" do
      post switch_account_path(account)
      expect(response).to redirect_to(account_path(account))
      expect(flash[:notice]).to include("Switched to")
    end

    it "updates user's current_workspace_id" do
      post switch_account_path(account)
      expect(user.reload.current_workspace).to be_present
      expect(user.current_workspace.account).to eq(account)
    end

    it "stores workspace_id in session" do
      post switch_account_path(account)
      expect(session[:current_workspace_id]).to be_present
    end

    context "when user has no access to account" do
      let(:other_account) { create(:account) }

      it "denies access" do
        post switch_account_path(other_account)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("not authorized")
      end
    end

    context "when account has no accessible workspaces" do
      let(:empty_account) { create(:account) }

      before do
        create(:account_membership, user: user, account: empty_account, role: :member, status: :active)
      end

      it "shows appropriate error" do
        post switch_account_path(empty_account)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("No accessible workspaces")
      end
    end
  end

  describe "POST /accounts/:account_id/workspaces/:id/switch" do
    it "switches to the workspace" do
      post switch_account_workspace_path(account, workspace2)
      expect(response).to redirect_to(account_workspace_path(account, workspace2))
      expect(flash[:notice]).to include("Switched to #{workspace2.name}")
    end

    it "updates user's current_workspace_id" do
      post switch_account_workspace_path(account, workspace2)
      expect(user.reload.current_workspace).to eq(workspace2)
    end

    it "stores workspace_id in session" do
      post switch_account_workspace_path(account, workspace2)
      expect(session[:current_workspace_id]).to eq(workspace2.id)
    end

    context "when user has no workspace membership" do
      let(:other_workspace) { create(:workspace, account: account) }

      it "denies access" do
        post switch_account_workspace_path(account, other_workspace)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("not authorized")
      end
    end

    context "cross-account workspace access" do
      let(:other_account) { create(:account) }
      let(:other_workspace) { create(:workspace, account: other_account, name: "Other Workspace") }

      before do
        create(:account_membership, user: user, account: other_account, role: :member, status: :active)
        create(:workspace_membership, user: user, workspace: other_workspace, role: :member, status: :active)
      end

      it "denies access when using wrong account_id in URL" do
        # Trying to access other_workspace through wrong account
        # The workspace lookup is scoped to @account, so it will not find other_workspace
        # In request specs, Rails rescues RecordNotFound and returns 404
        post switch_account_workspace_path(account, other_workspace)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "workspace context persistence" do
    it "maintains workspace selection across requests" do
      post switch_account_workspace_path(account, workspace2)

      # Make another request
      get account_workspace_path(account, workspace2)

      # User should still have workspace2 as current
      expect(user.reload.current_workspace).to eq(workspace2)
    end

    it "stores selection in session" do
      post switch_account_workspace_path(account, workspace1)

      expect(session[:current_workspace_id]).to eq(workspace1.id)

      # Switch to workspace2
      post switch_account_workspace_path(account, workspace2)

      expect(session[:current_workspace_id]).to eq(workspace2.id)
    end
  end

  context "when not signed in" do
    before { sign_out user }

    it "redirects to sign in for account switch" do
      post switch_account_path(account)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects to sign in for workspace switch" do
      post switch_account_workspace_path(account, workspace1)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "audit logging", :aggregate_failures do
    it "logs account switch event" do
      expect do
        post switch_account_path(account)
      end.to change(AuditEvent, :count).by(1)

      event = AuditEvent.last
      expect(event.action).to eq(AuditEvent::ACTION_ACCOUNT_SWITCH)
      expect(event.auditable).to eq(account)
      expect(event.user).to eq(user)
      expect(event.metadata["new_account_id"]).to eq(account.id)
    end

    it "logs workspace switch event" do
      expect do
        post switch_account_workspace_path(account, workspace2)
      end.to change(AuditEvent, :count).by(1)

      event = AuditEvent.last
      expect(event.action).to eq(AuditEvent::ACTION_WORKSPACE_SWITCH)
      expect(event.auditable).to eq(workspace2)
      expect(event.user).to eq(user)
      expect(event.metadata["new_workspace_id"]).to eq(workspace2.id)
    end
  end
end
