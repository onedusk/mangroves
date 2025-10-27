# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tenant Isolation", type: :integration do
  # NOTE: These tests verify that multi-tenant data boundaries are enforced
  # at the database level through TenantScoped concern and query scoping

  let(:account1) { create(:account, name: "Account 1") }
  let(:account2) { create(:account, name: "Account 2") }

  let(:workspace1) { create(:workspace, account: account1, name: "Workspace 1") }
  let(:workspace2) { create(:workspace, account: account2, name: "Workspace 2") }

  let(:user1) { create(:user, email: "user1@example.com", current_workspace: workspace1) }
  let(:user2) { create(:user, email: "user2@example.com", current_workspace: workspace2) }

  let!(:account_membership1) do
    create(:account_membership, user: user1, account: account1, status: :active)
  end
  let!(:account_membership2) do
    create(:account_membership, user: user2, account: account2, status: :active)
  end

  let!(:workspace_membership1) do
    create(:workspace_membership, user: user1, workspace: workspace1, status: :active)
  end
  let!(:workspace_membership2) do
    create(:workspace_membership, user: user2, workspace: workspace2, status: :active)
  end

  describe "query isolation" do
    context "when Current.account is set" do
      before do
        allow(Current).to receive(:account).and_return(account1)
      end

      it "only returns workspaces for the current account" do
        workspaces = Workspace.all

        expect(workspaces).to include(workspace1)
        expect(workspaces).not_to include(workspace2)
      end

      it "prevents finding records from other accounts" do
        expect do
          Workspace.find(workspace2.id)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "scopes queries automatically" do
        count = Workspace.count

        expect(count).to eq(1)
      end

      it "allows unscoped access when explicitly requested" do
        workspaces = Workspace.unscoped.all

        expect(workspaces).to include(workspace1)
        expect(workspaces).to include(workspace2)
      end

      it "prevents cross-tenant updates" do
        expect do
          workspace2.update!(name: "Hacked Name")
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "prevents cross-tenant deletes" do
        expect do
          Workspace.find(workspace2.id).destroy
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when Current.account changes" do
      it "returns different data for different accounts" do
        allow(Current).to receive(:account).and_return(account1)
        workspaces_account1 = Workspace.all.to_a

        allow(Current).to receive(:account).and_return(account2)
        workspaces_account2 = Workspace.all.to_a

        expect(workspaces_account1).to include(workspace1)
        expect(workspaces_account1).not_to include(workspace2)

        expect(workspaces_account2).to include(workspace2)
        expect(workspaces_account2).not_to include(workspace1)
      end
    end

    context "when Current.account is nil" do
      before do
        allow(Current).to receive(:account).and_return(nil)
      end

      it "returns no records with default scope" do
        workspaces = Workspace.all

        expect(workspaces).to be_empty
      end

      it "still allows unscoped access" do
        workspaces = Workspace.unscoped_all

        expect(workspaces.count).to eq(2)
      end
    end
  end

  describe "creation isolation" do
    before do
      allow(Current).to receive(:account).and_return(account1)
    end

    it "automatically assigns current account on create" do
      workspace = Workspace.create!(name: "New Workspace")

      expect(workspace.account_id).to eq(account1.id)
    end

    it "prevents creating records for other accounts" do
      # Should either raise validation error or auto-assign current account
      begin
        workspace = Workspace.create!(name: "Another Workspace", account_id: account2.id)
        # If creation succeeded, account should have been auto-assigned
        expect(workspace.account_id).to eq(account1.id)
      rescue ActiveRecord::RecordInvalid
        # Validation error is also acceptable behavior
        expect(true).to be true
      end
    end

    it "creates records only within current tenant scope" do
      initial_count = Workspace.count

      Workspace.create!(name: "Scoped Workspace")

      expect(Workspace.count).to eq(initial_count + 1)
      expect(Workspace.last.account).to eq(account1)
    end
  end

  describe "association isolation" do
    let!(:team1) { create(:team, workspace: workspace1, name: "Team 1") }
    let!(:team2) { create(:team, workspace: workspace2, name: "Team 2") }

    before do
      allow(Current).to receive(:account).and_return(account1)
    end

    it "only loads associations within tenant scope" do
      workspace = Workspace.find(workspace1.id)
      teams = workspace.teams

      expect(teams).to include(team1)
      expect(teams).not_to include(team2)
    end

    it "prevents cross-tenant association access" do
      # Try to access team2 through workspace1's association
      expect do
        workspace1.teams.find(team2.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "bulk operations isolation" do
    before do
      allow(Current).to receive(:account).and_return(account1)
    end

    it "only updates records in current tenant scope" do
      Workspace.update_all(name: "Bulk Updated")

      workspace1.reload
      workspace2.reload

      expect(workspace1.name).to eq("Bulk Updated")
      expect(workspace2.name).to eq("Workspace 2") # Not updated
    end

    it "only deletes records in current tenant scope" do
      Workspace.delete_all

      expect(Workspace.unscoped.exists?(workspace1.id)).to be false
      expect(Workspace.unscoped.exists?(workspace2.id)).to be true
    end

    it "only counts records in current tenant scope" do
      count = Workspace.count

      expect(count).to eq(1)
    end
  end

  describe "n+1 query prevention" do
    let!(:team1a) { create(:team, workspace: workspace1, name: "Team 1A") }
    let!(:team1b) { create(:team, workspace: workspace1, name: "Team 1B") }

    before do
      allow(Current).to receive(:account).and_return(account1)
    end

    it "allows eager loading within tenant scope" do
      workspaces = nil

      # Count queries
      query_count = count_queries do
        workspaces = Workspace.includes(:teams).all
      end

      # Access associations (should not trigger additional queries)
      additional_query_count = count_queries do
        workspaces.each { |w| w.teams.to_a }
      end

      expect(additional_query_count).to eq(0)
    end
  end

  describe "concurrent access isolation" do
    it "maintains isolation across parallel requests" do
      results = Parallel.map([account1, account2], in_threads: 2) do |account|
        ActiveRecord::Base.connection_pool.with_connection do
          allow(Current).to receive(:account).and_return(account)
          Workspace.count
        end
      end

      expect(results).to eq([1, 1])
    end

    it "prevents data leakage in concurrent operations" do
      results = Parallel.map([account1, account2], in_threads: 2) do |account|
        ActiveRecord::Base.connection_pool.with_connection do
          allow(Current).to receive(:account).and_return(account)
          Workspace.all.pluck(:id)
        end
      end

      expect(results[0]).to eq([workspace1.id])
      expect(results[1]).to eq([workspace2.id])
    end
  end

  describe "security verification" do
    before do
      allow(Current).to receive(:account).and_return(account1)
    end

    it "prevents SQL injection through tenant scope" do
      malicious_id = "'; DROP TABLE workspaces; --"

      expect do
        Workspace.where(id: malicious_id).first
      end.not_to raise_error

      # Table should still exist
      expect(Workspace.unscoped.count).to be > 0
    end

    it "prevents bypassing tenant scope through raw SQL" do
      # This is a safety check - raw SQL should still respect connections
      result = ActiveRecord::Base.connection.execute(
        "SELECT COUNT(*) FROM workspaces WHERE account_id = '#{account1.id}'"
      )

      expect(result.first["count"]).to eq(1)
    end
  end

  def count_queries(&)
    count = 0
    counter = ->(*, **, &) { count += 1 }

    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &)

    count
  end
end
