# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeamPolicy, type: :policy do
  subject(:policy) { described_class.new(user, team) }

  let(:user) { create(:user) }
  let(:account) { create(:account) }
  let(:workspace) { create(:workspace, account:) }
  let(:team) { create(:team, workspace:, account:) }
  let(:other_account) { create(:account) }
  let(:other_workspace) { create(:workspace, account: other_account) }
  let(:other_team) { create(:team, workspace: other_workspace, account: other_account) }

  describe "#index?" do
    context "without workspace access" do
      it "denies access" do
        expect(policy.index?).to be false
      end
    end

    context "with workspace viewer role only" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :viewer, status: :active) }

      it "denies access" do
        expect(policy.index?).to be false
      end
    end

    context "with workspace member role" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :member, status: :active) }

      it "permits access" do
        expect(policy.index?).to be true
      end
    end

    context "with workspace admin role" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :admin, status: :active) }

      it "permits access" do
        expect(policy.index?).to be true
      end
    end
  end

  describe "#show?" do
    context "without team membership" do
      it "denies access" do
        expect(policy.show?).to be false
      end
    end

    context "with team member role" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :member, status: :active) }
      let!(:team_membership) { create(:team_membership, user:, team:, role: :member, status: :active) }

      it "permits access" do
        expect(policy.show?).to be true
      end
    end

    context "with team lead role" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :member, status: :active) }
      let!(:team_membership) { create(:team_membership, user:, team:, role: :lead, status: :active) }

      it "permits access" do
        expect(policy.show?).to be true
      end
    end
  end

  describe "#create?" do
    context "with workspace member role" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :member, status: :active) }

      it "permits access" do
        expect(policy.create?).to be true
      end
    end

    context "without workspace membership" do
      it "denies access" do
        expect(policy.create?).to be false
      end
    end
  end

  describe "#update?" do
    context "with team member role" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :member, status: :active) }
      let!(:team_membership) { create(:team_membership, user:, team:, role: :member, status: :active) }

      it "denies access" do
        expect(policy.update?).to be false
      end
    end

    context "with team lead role" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :member, status: :active) }
      let!(:team_membership) { create(:team_membership, user:, team:, role: :lead, status: :active) }

      it "permits access" do
        expect(policy.update?).to be true
      end
    end
  end

  describe "#destroy?" do
    context "with team member role" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :member, status: :active) }
      let!(:team_membership) { create(:team_membership, user:, team:, role: :member, status: :active) }

      it "denies access" do
        expect(policy.destroy?).to be false
      end
    end

    context "with team lead role" do
      let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
      let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :member, status: :active) }
      let!(:team_membership) { create(:team_membership, user:, team:, role: :lead, status: :active) }

      it "permits access" do
        expect(policy.destroy?).to be true
      end
    end
  end

  describe "cross-workspace access" do
    let!(:other_account_membership) do
      create(:account_membership, user:, account: other_account, role: :owner, status: :active)
    end
    let!(:other_workspace_membership) do
      create(:workspace_membership, user:, workspace: other_workspace, role: :owner, status: :active)
    end
    let!(:other_team_membership) { create(:team_membership, user:, team: other_team, role: :lead, status: :active) }

    subject(:policy) { described_class.new(user, team) }

    it "denies access to team in different workspace" do
      expect(policy.index?).to be false
      expect(policy.show?).to be false
      expect(policy.create?).to be false
      expect(policy.update?).to be false
      expect(policy.destroy?).to be false
    end
  end

  describe "scope" do
    let!(:team1) { create(:team, workspace:, account:) }
    let!(:team2) { create(:team, workspace:, account:) }
    let!(:team3) { create(:team, workspace: other_workspace, account: other_account) }
    let!(:account_membership) { create(:account_membership, user:, account:, role: :member, status: :active) }
    let!(:workspace_membership) { create(:workspace_membership, user:, workspace:, role: :member, status: :active) }
    let!(:team_membership1) { create(:team_membership, user:, team: team1, status: :active) }
    let!(:team_membership2) { create(:team_membership, user:, team: team2, status: :active) }

    it "returns only teams the user belongs to" do
      resolved = Pundit.policy_scope(user, Team)
      expect(resolved).to contain_exactly(team1, team2)
      expect(resolved).not_to include(team3)
    end
  end
end
