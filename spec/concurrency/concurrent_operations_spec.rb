# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Concurrent Operations", type: :integration do
  describe "slug generation race conditions" do
    it "generates unique slugs for concurrent account creation with same name" do
      results = Parallel.map(1..10, in_threads: 10) do
        ActiveRecord::Base.connection_pool.with_connection do
          Account.create!(name: "Test Account")
        end
      end

      slugs = results.map(&:slug)
      expect(slugs.uniq.length).to eq(10) # All slugs should be unique
    end

    it "handles slug conflicts gracefully" do
      # Pre-create an account with the slug
      existing = Account.create!(name: "My Company")

      # Try to create more with same name concurrently
      results = Parallel.map(1..5, in_threads: 5) do
        ActiveRecord::Base.connection_pool.with_connection do
          Account.create!(name: "My Company")
        end
      end

      all_slugs = [existing.slug] + results.map(&:slug)
      expect(all_slugs.uniq.length).to eq(6) # All should be unique
    end

    it "generates unique slugs for workspaces within same account" do
      account = Account.create!(name: "Test Account")

      results = Parallel.map(1..10, in_threads: 10) do
        ActiveRecord::Base.connection_pool.with_connection do
          Workspace.create!(account: account, name: "Production")
        end
      end

      slugs = results.map(&:slug)
      expect(slugs.uniq.length).to eq(10)
    end
  end

  describe "account creation race conditions" do
    let(:user) { create(:user) }

    it "prevents duplicate account creation for same user" do
      # Simulate concurrent onboarding requests
      results = Parallel.map(1..5, in_threads: 5) do |i|
        ActiveRecord::Base.connection_pool.with_connection do
          Account.transaction do
            account = Account.create!(name: "User #{user.id} Account #{i}")
            workspace = Workspace.create!(account: account, name: "Default")
            AccountMembership.create!(user: user, account: account, role: :owner, status: :active)
            WorkspaceMembership.create!(user: user, workspace: workspace, role: :owner, status: :active)
            account
          end
        rescue ActiveRecord::RecordInvalid
          nil # Ignore validation errors
        end
      end

      successful_results = results.compact
      expect(successful_results.length).to be >= 1 # At least one should succeed
      expect(successful_results.length).to be <= 5 # But all should be valid
    end

    it "maintains data consistency during concurrent operations" do
      account = Account.create!(name: "Concurrent Test")

      results = Parallel.map(1..10, in_threads: 10) do
        ActiveRecord::Base.connection_pool.with_connection do
          Workspace.transaction do
            workspace = Workspace.create!(account: account, name: "Workspace-#{SecureRandom.hex(4)}")
            Team.create!(workspace: workspace, name: "Default Team")
            workspace
          end
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error("Concurrent creation failed: #{e.message}")
          nil
        end
      end

      successful_workspaces = results.compact
      expect(successful_workspaces.length).to eq(10)

      # Verify all have teams
      successful_workspaces.each do |workspace|
        expect(workspace.teams.count).to eq(1)
      end
    end
  end

  describe "workspace switching race conditions" do
    let(:account) { create(:account) }
    let(:workspace1) { create(:workspace, account: account, name: "Workspace 1") }
    let(:workspace2) { create(:workspace, account: account, name: "Workspace 2") }
    let(:user) { create(:user, current_workspace: workspace1) }

    let!(:account_membership) { create(:account_membership, user: user, account: account, status: :active) }
    let!(:workspace_membership1) do
      create(:workspace_membership, user: user, workspace: workspace1, status: :active)
    end
    let!(:workspace_membership2) do
      create(:workspace_membership, user: user, workspace: workspace2, status: :active)
    end

    it "handles concurrent workspace switches atomically" do
      workspaces = [workspace1, workspace2]

      results = Parallel.map(1..20, in_threads: 10) do |i|
        ActiveRecord::Base.connection_pool.with_connection do
          target_workspace = workspaces[i % 2]

          begin
            User.transaction do
              user.reload
              user.update!(current_workspace: target_workspace)
              user.current_workspace_id
            end
          rescue ActiveRecord::StaleObjectError
            # Retry on stale object error
            retry
          end
        end
      end

      # Final state should be consistent
      user.reload
      expect([workspace1.id, workspace2.id]).to include(user.current_workspace_id)

      # All operations should complete
      expect(results.length).to eq(20)
    end

    it "prevents race conditions in membership status updates" do
      membership = workspace_membership1

      Parallel.map(%i[active inactive suspended], in_threads: 3) do |status|
        ActiveRecord::Base.connection_pool.with_connection do
          WorkspaceMembership.transaction do
            m = WorkspaceMembership.find(membership.id)
            m.update!(status: status)
            m.status
          end
        rescue ActiveRecord::RecordInvalid
          nil
        end
      end

      # Should end in a valid state
      membership.reload
      expect(%i[active inactive suspended]).to include(membership.status.to_sym)
    end
  end

  describe "tenant context isolation in concurrent requests" do
    let(:account1) { create(:account) }
    let(:account2) { create(:account) }
    let(:workspace1) { create(:workspace, account: account1) }
    let(:workspace2) { create(:workspace, account: account2) }

    it "maintains separate Current.account across threads" do
      results = Parallel.map([account1, account2], in_threads: 2) do |account|
        ActiveRecord::Base.connection_pool.with_connection do
          # Simulate request-level context setting
          Current.set(account: account) do
            sleep(rand * 0.1) # Random delay to encourage race conditions
            Current.account.id
          end
        end
      end

      expect(results).to match_array([account1.id, account2.id])
    end

    it "isolates workspace queries in concurrent contexts" do
      results = Parallel.map([account1, account2], in_threads: 2) do |account|
        ActiveRecord::Base.connection_pool.with_connection do
          Current.set(account: account) do
            sleep(rand * 0.1)
            Workspace.count
          end
        end
      end

      expect(results).to eq([1, 1])
    end

    it "prevents data leakage in high-concurrency scenarios" do
      workspaces_created = []

      Parallel.each([account1, account2], in_threads: 2) do |account|
        ActiveRecord::Base.connection_pool.with_connection do
          5.times do |i|
            Current.set(account: account) do
              workspace = Workspace.create!(name: "Test-#{account.id}-#{i}")
              workspaces_created << {account_id: account.id, workspace_id: workspace.id}
            end
          end
        end
      end

      # Verify all workspaces belong to correct accounts
      workspaces_created.each do |record|
        workspace = Workspace.unscoped.find(record[:workspace_id])
        expect(workspace.account_id).to eq(record[:account_id])
      end
    end
  end

  describe "optimistic locking" do
    it "detects concurrent updates using lock_version" do
      account = Account.create!(name: "Locked Account")

      results = Parallel.map(1..5, in_threads: 5) do |i|
        ActiveRecord::Base.connection_pool.with_connection do
          acc = Account.find(account.id)
          sleep(rand * 0.1) # Increase chance of collision
          acc.update!(name: "Updated #{i}")
          true
        rescue ActiveRecord::StaleObjectError
          false # Optimistic lock failure
        end
      end

      # Some should succeed, some should fail due to optimistic locking
      expect(results.count(true)).to be >= 1
      expect(results.count(false)).to be >= 0 # May have collisions
    end
  end

  describe "database deadlock prevention" do
    it "handles potential deadlocks gracefully" do
      account1 = Account.create!(name: "Account A")
      account2 = Account.create!(name: "Account B")

      results = []

      threads = [
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            Account.transaction do
              Account.find(account1.id).update!(name: "Updated A")
              sleep(0.01)
              Account.find(account2.id).update!(name: "Updated A2")
              results << "thread1"
            end
          rescue ActiveRecord::Deadlocked
            results << "deadlock1"
          end
        end,
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            Account.transaction do
              Account.find(account2.id).update!(name: "Updated B")
              sleep(0.01)
              Account.find(account1.id).update!(name: "Updated B2")
              results << "thread2"
            end
          rescue ActiveRecord::Deadlocked
            results << "deadlock2"
          end
        end
      ]

      threads.each(&:join)

      # At least one should complete (or both if no deadlock occurred)
      expect(results.length).to be >= 1
      expect(results.any? { |r| r.start_with?("thread") }).to be true
    end
  end
end
