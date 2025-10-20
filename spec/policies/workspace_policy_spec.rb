# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkspacePolicy, type: :policy do
  subject(:policy) { described_class.new(user, workspace) }

  let(:user) { create(:user) }
  let(:account) { create(:account) }
  let(:workspace) { create(:workspace, account:) }
  let(:other_account) { create(:account) }
  let(:other_workspace) { create(:workspace, account: other_account) }

  describe "#index?" do
    context "without account access" do
      it "denies access" do
        expect(policy.index?).to be false
      end
    end

    context "with account viewer role only" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :viewer, status: :active) }

      it "denies access" do
        expect(policy.index?).to be false
      end
    end

    context "with account member role" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }

      it "permits access" do
        expect(policy.index?).to be true
      end
    end

    context "with account admin role" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :admin, status: :active) }

      it "permits access" do
        expect(policy.index?).to be true
      end
    end
  end

  describe "#show?" do
    context "without workspace membership" do
      it "denies access" do
        expect(policy.show?).to be false
      end
    end

    context "with workspace viewer membership" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :viewer, status: :active) }

      it "permits access" do
        expect(policy.show?).to be true
      end
    end

    context "with workspace member membership" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :member, status: :active) }

      it "permits access" do
        expect(policy.show?).to be true
      end
    end

    context "with workspace admin membership" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :admin, status: :active) }

      it "permits access" do
        expect(policy.show?).to be true
      end
    end

    context "with workspace owner membership" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :owner, status: :active) }

      it "permits access" do
        expect(policy.show?).to be true
      end
    end
  end

  describe "#create?" do
    context "with account member role" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }

      it "permits access" do
        expect(policy.create?).to be true
      end
    end

    context "without account membership" do
      it "denies access" do
        expect(policy.create?).to be false
      end
    end
  end

  describe "#update?" do
    context "with workspace viewer membership" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :viewer, status: :active) }

      it "denies access" do
        expect(policy.update?).to be false
      end
    end

    context "with workspace member membership" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :member, status: :active) }

      it "denies access" do
        expect(policy.update?).to be false
      end
    end

    context "with workspace admin membership" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :admin, status: :active) }

      it "permits access" do
        expect(policy.update?).to be true
      end
    end

    context "with workspace owner membership" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :owner, status: :active) }

      it "permits access" do
        expect(policy.update?).to be true
      end
    end
  end

  describe "#destroy?" do
    context "with workspace admin membership" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :admin, status: :active) }

      it "denies access" do
        expect(policy.destroy?).to be false
      end
    end

    context "with workspace owner membership" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :owner, status: :active) }

      it "permits access" do
        expect(policy.destroy?).to be true
      end
    end
  end

  describe "cross-account access" do
    let!(:other_account_membership) do
      create(:account_membership, user:, account: other_account, role: :owner, status: :active)
    end
    let!(:other_workspace_membership) do
      create(:workspace_membership, user:, workspace: other_workspace, role: :owner, status: :active)
    end

    subject(:policy) { described_class.new(user, workspace) }

    it "denies access to workspace in different account" do
      expect(policy.index?).to be false
      expect(policy.show?).to be false
      expect(policy.create?).to be false
      expect(policy.update?).to be false
      expect(policy.destroy?).to be false
    end
  end

  describe "scope" do
    let!(:workspace1) { create(:workspace, account:) }
    let!(:workspace2) { create(:workspace, account:) }
    let!(:workspace3) { create(:workspace, account: other_account) }
    let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
    let!(:workspace_membership1) { create(:workspace_membership, user:, workspace: workspace1, status: :active) }
    let!(:workspace_membership2) { create(:workspace_membership, user:, workspace: workspace2, status: :active) }

    it "returns only workspaces the user belongs to" do
      resolved = Pundit.policy_scope(user, Workspace)
      expect(resolved).to contain_exactly(workspace1, workspace2)
      expect(resolved).not_to include(workspace3)
    end
  end
end
