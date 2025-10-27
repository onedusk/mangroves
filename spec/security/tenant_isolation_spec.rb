# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tenant Isolation Security" do
  around do |example|
    Current.reset
    example.run
    Current.reset
  end

  let(:account_a) { create(:account, name: "Account A") }
  let(:account_b) { create(:account, name: "Account B") }

  describe "TenantScoped concern" do
    describe "default scope with nil Current.account" do
      it "returns zero records for Workspace when Current.account is nil" do
        Current.account = account_a
        create(:workspace, name: "Workspace A")

        Current.account = account_b
        create(:workspace, name: "Workspace B")

        # CRITICAL: Must return zero records, not all records
        Current.account = nil
        expect(Workspace.count).to eq(0)
        expect(Workspace.all.to_a).to eq([])
      end

      it "returns zero records for Team when Current.account is nil" do
        Current.account = account_a
        workspace_a = create(:workspace, name: "Workspace A")
        create(:team, workspace: workspace_a, name: "Team A")

        Current.account = account_b
        workspace_b = create(:workspace, name: "Workspace B")
        create(:team, workspace: workspace_b, name: "Team B")

        Current.account = nil
        expect(Team.count).to eq(0)
        expect(Team.all.to_a).to eq([])
      end
    end

    describe "cross-tenant query isolation" do
      it "prevents cross-tenant queries on Workspace" do
        Current.account = account_a
        workspace_a = create(:workspace, name: "Workspace A")

        Current.account = account_b
        workspace_b = create(:workspace, name: "Workspace B")

        # Switch back to account_a
        Current.account = account_a
        results = Workspace.all.to_a

        expect(results).to contain_exactly(workspace_a)
        expect(results).not_to include(workspace_b)
      end

      it "prevents cross-tenant queries on Team" do
        Current.account = account_a
        workspace_a = create(:workspace, name: "Workspace A")
        team_a = create(:team, workspace: workspace_a, name: "Team A")

        Current.account = account_b
        workspace_b = create(:workspace, name: "Workspace B")
        team_b = create(:team, workspace: workspace_b, name: "Team B")

        Current.account = account_a
        results = Team.all.to_a

        expect(results).to contain_exactly(team_a)
        expect(results).not_to include(team_b)
      end

      it "prevents finding records from other tenants by ID" do
        Current.account = account_a
        create(:workspace, name: "Workspace A")

        Current.account = account_b
        workspace_b = create(:workspace, name: "Workspace B")
        workspace_b_id = workspace_b.id

        # Try to find account_b's workspace while in account_a context
        Current.account = account_a
        expect do
          Workspace.find(workspace_b_id)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "explicit account validation" do
      it "requires account to be present on create" do
        Current.account = nil
        workspace = Workspace.new(name: "Test Workspace")

        expect(workspace).not_to be_valid
        expect(workspace.errors[:account]).to include("can't be blank")
      end

      it "validates account matches Current.account on Team creation" do
        Current.account = account_a
        workspace_a = create(:workspace)

        # Try to create team with mismatched account
        Current.account = account_b
        team = Team.new(
          workspace: workspace_a,
          name: "Test Team",
          account: account_b
        )

        expect(team).not_to be_valid
        expect(team.errors[:account]).to be_present
      end
    end
  end

  describe "Workspace slug generation" do
    it "generates unique slugs with counter suffix" do
      Current.account = account_a

      # Create workspaces without preset slugs (slug will be auto-generated)
      workspace1 = Workspace.create!(name: "Test", account: account_a)
      workspace2 = Workspace.create!(name: "Test", account: account_a)

      expect(workspace1.slug).to eq("test")
      expect(workspace2.slug).to eq("test-1")
      expect(workspace1.slug).not_to eq(workspace2.slug)
    end

    it "returns error when account is nil during slug generation" do
      Current.account = nil
      workspace = Workspace.new(name: "Test Workspace")

      workspace.save

      expect(workspace).not_to be_valid
      expect(workspace.errors[:account]).to be_present
    end

    it "scopes slug uniqueness check to account" do
      Current.account = account_a
      workspace_a = Workspace.create!(name: "Test Workspace", account: account_a)

      Current.account = account_b
      workspace_b = Workspace.create!(name: "Test Workspace", account: account_b)

      # Different accounts CAN have same slug (scoped by account_id)
      expect(workspace_a.slug).to eq("test-workspace")
      expect(workspace_b.slug).to eq("test-workspace")
    end
  end

  describe "Team account validation" do
    it "gets account from Current.account via TenantScoped" do
      Current.account = account_a
      workspace = create(:workspace)

      # Team should get account from Current.account (via TenantScoped)
      team = Team.new(workspace: workspace, name: "Test Team")

      # TenantScoped should set account to Current.account
      team.valid?
      expect(team.account).to eq(account_a)
    end

    it "validates account matches workspace account" do
      Current.account = account_a
      create(:workspace)

      Current.account = account_b
      workspace_b = create(:workspace)

      # Try to create team with mismatched accounts
      Current.account = account_a
      team = Team.new(
        workspace: workspace_b,  # From account_b
        name: "Test Team"
        # account will be set to account_a via TenantScoped
      )

      expect(team).not_to be_valid
      expect(team.errors[:account]).to be_present
    end

    it "validates account matches Current.account on create" do
      Current.account = account_a
      workspace = create(:workspace)

      team = Team.new(workspace: workspace, name: "Test Team")
      team.account = account_b  # Try to override with wrong account

      expect(team).not_to be_valid
      expect(team.errors[:account]).to include(/must match Current.account/)
    end
  end

  describe "component security" do
    let(:user) { create(:user, first_name: "Test", last_name: "User") }

    describe "WorkspaceSwitcherComponent" do
      it "only shows accounts user has access to" do
        # Create memberships for account_a only
        create(:account_membership, user: user, account: account_a, status: :active)

        Current.account = account_a
        workspace_a = create(:workspace, name: "Workspace A")
        create(:workspace_membership, user: user, workspace: workspace_a, status: :active)

        # Create account_b workspace without user access
        Current.account = account_b
        create(:workspace, name: "Workspace B")

        # Component should only show account_a
        component = WorkspaceSwitcherComponent.new(
          current_user: user,
          current_workspace: workspace_a
        )

        # Verify authorization checks exist
        expect(component.send(:user_can_access_account?, account_a)).to be(true)
        expect(component.send(:user_can_access_account?, account_b)).to be(false)
      end

      it "only shows workspaces user has explicit access to" do
        create(:account_membership, user: user, account: account_a, status: :active)

        Current.account = account_a
        workspace_accessible = create(:workspace, name: "Accessible")
        workspace_inaccessible = create(:workspace, name: "Inaccessible")

        # Grant access to only one workspace
        create(:workspace_membership, user: user, workspace: workspace_accessible, status: :active)

        component = WorkspaceSwitcherComponent.new(
          current_user: user,
          current_workspace: workspace_accessible
        )

        expect(component.send(:user_can_access_workspace?, workspace_accessible)).to be(true)
        expect(component.send(:user_can_access_workspace?, workspace_inaccessible)).to be(false)
      end
    end

    describe "TableComponent" do
      it "validates all records belong to Current.account" do
        Current.account = account_a
        workspace_a = create(:workspace, name: "Workspace A")

        Current.account = account_b
        workspace_b = create(:workspace, name: "Workspace B")

        # Try to render table with mixed tenant data
        Current.account = account_a
        mixed_data = [workspace_a, workspace_b]

        expect do
          TableComponent.new(data: mixed_data, columns: [:name])
        end.to raise_error(SecurityError, /Tenant isolation violation/)
      end

      it "allows rendering when all records belong to Current.account" do
        Current.account = account_a
        workspace1 = create(:workspace, name: "Workspace 1")
        workspace2 = create(:workspace, name: "Workspace 2")

        valid_data = [workspace1, workspace2]

        expect do
          TableComponent.new(data: valid_data, columns: [:name])
        end.not_to raise_error
      end

      it "skips validation when skip_tenant_check is true" do
        Current.account = account_a
        workspace_a = create(:workspace, name: "Workspace A")

        Current.account = account_b
        workspace_b = create(:workspace, name: "Workspace B")

        Current.account = account_a
        mixed_data = [workspace_a, workspace_b]

        expect do
          TableComponent.new(data: mixed_data, columns: [:name], skip_tenant_check: true)
        end.not_to raise_error
      end

      it "handles empty data gracefully" do
        Current.account = account_a

        expect do
          TableComponent.new(data: [], columns: [:name])
        end.not_to raise_error
      end

      it "handles non-tenant-scoped data gracefully" do
        Current.account = account_a
        plain_data = [{name: "Item 1"}, {name: "Item 2"}]

        expect do
          TableComponent.new(data: plain_data, columns: [:name])
        end.not_to raise_error
      end
    end
  end

  describe "unscoped_all helper" do
    it "returns all records bypassing tenant scope" do
      Current.account = account_a
      workspace_a = create(:workspace, name: "Workspace A")

      Current.account = account_b
      workspace_b = create(:workspace, name: "Workspace B")

      Current.account = account_a
      scoped_results = Workspace.all.to_a
      unscoped_results = Workspace.unscoped_all.to_a

      expect(scoped_results).to contain_exactly(workspace_a)
      expect(unscoped_results).to contain_exactly(workspace_a, workspace_b)
    end
  end

  describe "edge cases" do
    it "handles rapid tenant switching correctly" do
      Current.account = account_a
      workspace_a = create(:workspace, name: "Workspace A")

      Current.account = account_b
      workspace_b = create(:workspace, name: "Workspace B")

      # Rapid switches
      10.times do
        Current.account = account_a
        expect(Workspace.all.to_a).to contain_exactly(workspace_a)

        Current.account = account_b
        expect(Workspace.all.to_a).to contain_exactly(workspace_b)
      end
    end

    it "maintains isolation after failed create attempts" do
      Current.account = account_a
      valid_workspace = create(:workspace, name: "Valid")

      # Try to create invalid workspace
      invalid_workspace = Workspace.new(name: "")
      invalid_workspace.save

      # Ensure scope still works
      expect(Workspace.all.to_a).to contain_exactly(valid_workspace)
    end

    it "prevents update to different tenant" do
      Current.account = account_a
      workspace = create(:workspace, name: "Test")
      workspace.id

      # Try to update account_id to different tenant
      expect do
        workspace.update!(account: account_b)
      end.to raise_error(ActiveRecord::RecordInvalid)

      # Verify workspace still belongs to account_a
      workspace.reload
      expect(workspace.account).to eq(account_a)
    end
  end
end
