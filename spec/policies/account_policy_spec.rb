# frozen_string_literal: true

require "rails_helper"

RSpec.describe AccountPolicy, type: :policy do
  subject(:policy) { described_class.new(user, account) }

  let(:user) { create(:user) }
  let(:account) { create(:account) }
  let(:other_account) { create(:account) }

  describe "#index?" do
    it "permits any authenticated user" do
      expect(policy.index?).to be true
    end
  end

  describe "#show?" do
    context "with viewer role" do
      let!(:membership) { create(:account_membership, user:, account:, role: :viewer, status: :active) }

      it "permits access" do
        expect(policy.show?).to be true
      end
    end

    context "with member role" do
      let!(:membership) { create(:account_membership, user:, account:, role: :member, status: :active) }

      it "permits access" do
        expect(policy.show?).to be true
      end
    end

    context "with admin role" do
      let!(:membership) { create(:account_membership, user:, account:, role: :admin, status: :active) }

      it "permits access" do
        expect(policy.show?).to be true
      end
    end

    context "with owner role" do
      let!(:membership) { create(:account_membership, user:, account:, role: :owner, status: :active) }

      it "permits access" do
        expect(policy.show?).to be true
      end
    end

    context "without membership" do
      it "denies access" do
        expect(policy.show?).to be false
      end
    end

    context "with membership to different account" do
      let!(:membership) { create(:account_membership, user:, account: other_account, role: :owner, status: :active) }

      it "denies access" do
        expect(policy.show?).to be false
      end
    end
  end

  describe "#create?" do
    it "permits any authenticated user to create accounts" do
      expect(policy.create?).to be true
    end
  end

  describe "#update?" do
    context "with viewer role" do
      let!(:membership) { create(:account_membership, user:, account:, role: :viewer, status: :active) }

      it "denies access" do
        expect(policy.update?).to be false
      end
    end

    context "with member role" do
      let!(:membership) { create(:account_membership, user:, account:, role: :member, status: :active) }

      it "denies access" do
        expect(policy.update?).to be false
      end
    end

    context "with admin role" do
      let!(:membership) { create(:account_membership, user:, account:, role: :admin, status: :active) }

      it "permits access" do
        expect(policy.update?).to be true
      end
    end

    context "with owner role" do
      let!(:membership) { create(:account_membership, user:, account:, role: :owner, status: :active) }

      it "permits access" do
        expect(policy.update?).to be true
      end
    end

    context "without membership" do
      it "denies access" do
        expect(policy.update?).to be false
      end
    end
  end

  describe "#destroy?" do
    context "with viewer role" do
      let!(:membership) { create(:account_membership, user:, account:, role: :viewer, status: :active) }

      it "denies access" do
        expect(policy.destroy?).to be false
      end
    end

    context "with member role" do
      let!(:membership) { create(:account_membership, user:, account:, role: :member, status: :active) }

      it "denies access" do
        expect(policy.destroy?).to be false
      end
    end

    context "with admin role" do
      let!(:membership) { create(:account_membership, user:, account:, role: :admin, status: :active) }

      it "denies access" do
        expect(policy.destroy?).to be false
      end
    end

    context "with owner role" do
      let!(:membership) { create(:account_membership, user:, account:, role: :owner, status: :active) }

      it "permits access" do
        expect(policy.destroy?).to be true
      end
    end

    context "without membership" do
      it "denies access" do
        expect(policy.destroy?).to be false
      end
    end
  end

  describe "role hierarchy" do
    it "owner can do everything admin can do" do
      admin_user = create(:user)
      owner_user = create(:user)
      create(:account_membership, user: admin_user, account:, role: :admin, status: :active)
      create(:account_membership, user: owner_user, account:, role: :owner, status: :active)

      admin_policy = described_class.new(admin_user, account)
      owner_policy = described_class.new(owner_user, account)

      expect(admin_policy.show?).to be true
      expect(owner_policy.show?).to be true

      expect(admin_policy.update?).to be true
      expect(owner_policy.update?).to be true
    end

    it "admin can do everything member can do" do
      member_user = create(:user)
      admin_user = create(:user)
      create(:account_membership, user: member_user, account:, role: :member, status: :active)
      create(:account_membership, user: admin_user, account:, role: :admin, status: :active)

      member_policy = described_class.new(member_user, account)
      admin_policy = described_class.new(admin_user, account)

      expect(member_policy.show?).to be true
      expect(admin_policy.show?).to be true
    end

    it "member can do everything viewer can do" do
      viewer_user = create(:user)
      member_user = create(:user)
      create(:account_membership, user: viewer_user, account:, role: :viewer, status: :active)
      create(:account_membership, user: member_user, account:, role: :member, status: :active)

      viewer_policy = described_class.new(viewer_user, account)
      member_policy = described_class.new(member_user, account)

      expect(viewer_policy.show?).to be true
      expect(member_policy.show?).to be true
    end
  end

  describe "scope" do
    let!(:account1) { create(:account) }
    let!(:account2) { create(:account) }
    let!(:account3) { create(:account) }
    let!(:membership1) { create(:account_membership, user:, account: account1, status: :active) }
    let!(:membership2) { create(:account_membership, user:, account: account2, status: :active) }

    it "returns only accounts the user belongs to" do
      resolved = Pundit.policy_scope(user, Account)
      expect(resolved).to contain_exactly(account1, account2)
      expect(resolved).not_to include(account3)
    end
  end
end
