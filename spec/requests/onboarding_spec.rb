# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Onboarding", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /onboarding/new" do
    context "when user has no accounts" do
      it "shows the onboarding form" do
        get onboarding_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Welcome! Let's create your account")
      end
    end

    context "when user already has an account" do
      let!(:account) { create(:account) }
      let!(:membership) { create(:account_membership, user: user, account: account, role: :owner, status: :active) }

      it "redirects to root path" do
        get onboarding_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /onboarding/create" do
    let(:valid_params) { {account: {name: "My New Account"}} }

    context "with valid parameters" do
      it "creates a new account" do
        expect do
          post onboarding_create_path, params: valid_params
        end.to change(Account, :count).by(1)

        new_account = Account.last
        expect(new_account.name).to eq("My New Account")
        expect(new_account.owner).to eq(user)
      end

      it "creates a default workspace" do
        expect do
          post onboarding_create_path, params: valid_params
        end.to change(Workspace, :count).by(1)

        new_workspace = Workspace.last
        expect(new_workspace.name).to eq("Default")
        expect(new_workspace.slug).to eq("default")
        expect(new_workspace.account).to eq(Account.last)
      end

      it "creates an owner membership for the user" do
        expect do
          post onboarding_create_path, params: valid_params
        end.to change(AccountMembership, :count).by(1)

        membership = AccountMembership.last
        expect(membership.user).to eq(user)
        expect(membership.account).to eq(Account.last)
        expect(membership.role).to eq("owner")
        expect(membership.status).to eq("active")
        expect(membership.accepted_at).to be_present
      end

      it "sets the user's current_workspace_id to the new workspace" do
        post onboarding_create_path, params: valid_params

        user.reload
        new_workspace = Workspace.last
        expect(user.current_workspace_id).to eq(new_workspace.id)
      end

      it "redirects to the account page with success message" do
        post onboarding_create_path, params: valid_params

        new_account = Account.last
        expect(response).to redirect_to(account_path(new_account))
        follow_redirect!
        expect(response.body).to include("Welcome! Your account has been created successfully.")
      end

      it "creates all records in a single transaction" do
        # Test that transaction rollback works by simulating a validation error
        allow_any_instance_of(AccountMembership).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(AccountMembership.new))

        expect do
          post onboarding_create_path, params: valid_params
        end.to change(Account, :count).by(0)
          .and change(Workspace, :count).by(0)
          .and change(AccountMembership, :count).by(0)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { {account: {name: ""}} }

      it "does not create an account" do
        expect do
          post onboarding_create_path, params: invalid_params
        end.not_to change(Account, :count)
      end

      it "does not create a workspace" do
        expect do
          post onboarding_create_path, params: invalid_params
        end.not_to change(Workspace, :count)
      end

      it "does not create a membership" do
        expect do
          post onboarding_create_path, params: invalid_params
        end.not_to change(AccountMembership, :count)
      end

      it "does not update user's current_workspace_id" do
        original_workspace_id = user.current_workspace_id
        post onboarding_create_path, params: invalid_params

        user.reload
        expect(user.current_workspace_id).to eq(original_workspace_id)
      end

      it "re-renders the form with error message" do
        post onboarding_create_path, params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Failed to create account")
      end
    end

    context "end-to-end onboarding flow" do
      it "completes the full onboarding process successfully" do
        # Start with a new user who has no accounts
        new_user = create(:user, email: "newuser@example.com")
        sign_in new_user

        # User visits onboarding page
        get onboarding_path
        expect(response).to have_http_status(:success)

        # User submits the form
        account_name = "Test Organization"
        post onboarding_create_path, params: {account: {name: account_name}}

        # Verify all objects were created
        account = Account.find_by(name: account_name)
        expect(account).to be_present
        expect(account.owner).to eq(new_user)

        workspace = account.workspaces.first
        expect(workspace).to be_present
        expect(workspace.name).to eq("Default")

        membership = AccountMembership.find_by(user: new_user, account: account)
        expect(membership).to be_present
        expect(membership.role).to eq("owner")
        expect(membership.status).to eq("active")

        # Verify user can access the account
        new_user.reload
        expect(new_user.current_workspace).to eq(workspace)
        expect(new_user.current_account).to eq(account)

        # User is redirected to account page
        expect(response).to redirect_to(account_path(account))
      end
    end

    context "slug generation" do
      it "generates a slug from the account name" do
        post onboarding_create_path, params: {account: {name: "Test Account"}}

        account = Account.last
        expect(account.slug).to eq("test-account")
      end

      it "handles special characters in account names" do
        post onboarding_create_path, params: {account: {name: "Test & Co.!"}}

        account = Account.last
        expect(account.slug).to match(/\Atest-co/)
      end
    end
  end

  context "when not signed in" do
    before { sign_out user }

    it "redirects to sign in for GET /onboarding/new" do
      get onboarding_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects to sign in for POST /onboarding/create" do
      post onboarding_create_path, params: {account: {name: "Test"}}
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
