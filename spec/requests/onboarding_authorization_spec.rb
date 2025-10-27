# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Onboarding Authorization Flows", type: :request do
  let(:user) { create(:user) }

  describe "GET /onboarding" do
    context "when not authenticated" do
      it "redirects to sign in" do
        get onboarding_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      context "without account" do
        it "renders onboarding page" do
          get onboarding_path

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Create your account")
        end
      end

      context "with existing account" do
        let!(:account) { create(:account) }
        let!(:workspace) { create(:workspace, account: account) }
        let!(:account_membership) { create(:account_membership, user: user, account: account, status: :active) }
        let!(:workspace_membership) do
          create(:workspace_membership, user: user, workspace: workspace, status: :active)
        end

        before do
          user.update!(current_workspace: workspace)
        end

        it "redirects to dashboard" do
          get onboarding_path

          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  describe "POST /onboarding" do
    before { sign_in user }

    context "with valid parameters" do
      let(:valid_params) do
        {
          account: {
            name: "Acme Corp",
            workspace_name: "Production"
          }
        }
      end

      it "creates account and workspace" do
        expect do
          post onboarding_path, params: valid_params
        end.to change(Account, :count).by(1)
          .and change(Workspace, :count).by(1)
      end

      it "creates account membership for user as owner" do
        post onboarding_path, params: valid_params

        membership = user.account_memberships.last
        expect(membership.role).to eq("owner")
        expect(membership.status).to eq("active")
      end

      it "creates workspace membership for user as owner" do
        post onboarding_path, params: valid_params

        membership = user.workspace_memberships.last
        expect(membership.role).to eq("owner")
        expect(membership.status).to eq("active")
      end

      it "sets current workspace for user" do
        post onboarding_path, params: valid_params

        user.reload
        expect(user.current_workspace).to be_present
        expect(user.current_workspace.name).to eq("Production")
      end

      it "redirects to dashboard" do
        post onboarding_path, params: valid_params

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("Welcome")
      end

      it "creates account with unique slug" do
        post onboarding_path, params: valid_params

        account = Account.last
        expect(account.slug).to eq("acme-corp")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          account: {
            name: "",
            workspace_name: ""
          }
        }
      end

      it "does not create account or workspace" do
        expect do
          post onboarding_path, params: invalid_params
        end.not_to change(Account, :count)
      end

      it "re-renders onboarding page with errors" do
        post onboarding_path, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("can&#39;t be blank").or include("can't be blank")
      end
    end

    context "with duplicate account name" do
      let!(:existing_account) { create(:account, name: "Acme Corp") }
      let(:params) do
        {
          account: {
            name: "Acme Corp",
            workspace_name: "Production"
          }
        }
      end

      it "creates account with unique slug" do
        post onboarding_path, params: params

        account = Account.last
        expect(account.slug).not_to eq(existing_account.slug)
        expect(account.slug).to match(/acme-corp-\d+/)
      end
    end
  end

  describe "authorization enforcement" do
    before { sign_in user }

    it "prevents access to onboarding after account creation" do
      account = create(:account)
      workspace = create(:workspace, account: account)
      create(:account_membership, user: user, account: account, role: :owner, status: :active)
      create(:workspace_membership, user: user, workspace: workspace, role: :owner, status: :active)
      user.update!(current_workspace: workspace)

      get onboarding_path

      expect(response).to redirect_to(root_path)
    end

    it "allows onboarding access for users without account" do
      get onboarding_path

      expect(response).to have_http_status(:ok)
    end
  end
end
