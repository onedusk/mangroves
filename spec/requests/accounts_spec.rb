# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Accounts", type: :request do
  let(:user) { create(:user) }
  let(:account) { create(:account) }
  let!(:membership) { create(:account_membership, user: user, account: account, role: :admin, status: :active) }

  before { sign_in user }

  describe "GET /accounts" do
    it "returns successful response" do
      get accounts_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /accounts/:id" do
    it "shows account details" do
      get account_path(account)
      expect(response).to have_http_status(:success)
    end

    context "when user is not a member" do
      let(:other_account) { create(:account) }

      it "redirects with authorization error" do
        get account_path(other_account)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("not authorized")
      end
    end
  end

  describe "GET /accounts/new" do
    it "shows new account form" do
      get new_account_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /accounts" do
    let(:valid_params) { {account: {name: "Test Account"}} }

    it "creates new account" do
      expect do
        post accounts_path, params: valid_params
      end.to change(Account, :count).by(1)
    end

    it "creates owner membership for current user" do
      post accounts_path, params: valid_params
      new_account = Account.last
      membership = new_account.account_memberships.find_by(user: user)
      expect(membership.role).to eq("owner")
    end

    it "redirects to account show page" do
      post accounts_path, params: valid_params
      expect(response).to redirect_to(Account.last)
    end
  end

  describe "GET /accounts/:id/edit" do
    context "when user is admin" do
      it "shows edit form" do
        get edit_account_path(account)
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is viewer" do
      before { membership.update!(role: :viewer) }

      it "denies access" do
        get edit_account_path(account)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH /accounts/:id" do
    let(:update_params) { {account: {name: "Updated Name"}} }

    context "when user is admin" do
      it "updates the account" do
        patch account_path(account), params: update_params
        expect(account.reload.name).to eq("Updated Name")
      end
    end

    context "when user is viewer" do
      before { membership.update!(role: :viewer) }

      it "denies access" do
        patch account_path(account), params: update_params
        expect(response).to redirect_to(root_path)
        expect(account.reload.name).not_to eq("Updated Name")
      end
    end
  end

  describe "cross-tenant access" do
    let(:account_a) { create(:account, name: "Account A") }
    let(:account_b) { create(:account, name: "Account B") }
    let(:user_a) { create(:user) }

    before do
      create(:account_membership, user: user_a, account: account_a, role: :admin, status: :active)
      sign_in user_a
    end

    it "user in Account A cannot access Account B" do
      get account_path(account_b)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include("not authorized")
    end
  end

  context "when not signed in" do
    before { sign_out user }

    it "redirects to sign in" do
      get accounts_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
