# frozen_string_literal: true

require "rails_helper"

# SECURITY: Tests for CSRF protection
RSpec.describe "CSRF Protection", type: :request do
  let(:user) { create(:user) }
  let(:account) { create(:account, owner: user) }
  let(:workspace) { create(:workspace, account: account) }

  before do
    create(:account_membership, user: user, account: account, role: :owner)
    create(:workspace_membership, user: user, workspace: workspace, role: :owner)
    user.update!(current_workspace: workspace)
    sign_in user
  end

  describe "Account creation CSRF protection" do
    it "rejects requests without CSRF token" do
      # Simulate CSRF attack - POST without token
      post accounts_path, params: {account: {name: "Evil Account"}}, headers: {"HTTP_X_CSRF_TOKEN" => "invalid"}

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "accepts requests with valid CSRF token" do
      # Get CSRF token from session
      get new_account_path
      csrf_token = css_select("meta[name='csrf-token']").first["content"]

      post accounts_path,
        params: {account: {name: "Valid Account"}},
        headers: {"HTTP_X_CSRF_TOKEN" => csrf_token}

      expect(response).to have_http_status(:redirect)
    end
  end

  describe "Account update CSRF protection" do
    it "rejects PUT requests without CSRF token" do
      patch account_path(account),
        params: {account: {name: "Hacked"}},
        headers: {"HTTP_X_CSRF_TOKEN" => "invalid"}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(account.reload.name).not_to eq("Hacked")
    end
  end

  describe "DELETE action CSRF protection" do
    let(:workspace_to_delete) { create(:workspace, account: account) }

    it "rejects DELETE requests without CSRF token" do
      delete account_workspace_path(account, workspace_to_delete),
        headers: {"HTTP_X_CSRF_TOKEN" => "invalid"}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(Workspace.exists?(workspace_to_delete.id)).to be true
    end
  end
end
