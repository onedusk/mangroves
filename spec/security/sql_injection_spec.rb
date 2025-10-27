# frozen_string_literal: true

require "rails_helper"

# SECURITY: Tests for SQL injection prevention
RSpec.describe "SQL Injection Prevention", type: :model do
  let(:user) { create(:user) }
  let(:account) { create(:account, owner: user) }

  describe "Account slug SQL injection" do
    it "prevents SQL injection via slug parameter" do
      # Attempt SQL injection through slug
      malicious_slug = "'; DROP TABLE accounts; --"

      account = build(:account, slug: malicious_slug)
      expect(account).not_to be_valid

      # Verify table still exists
      expect(Account.connection.table_exists?("accounts")).to be true
    end

    it "sanitizes input in where clauses" do
      # Create legitimate account
      create(:account, slug: "legitimate")

      # Attempt to bypass where clause with SQL injection
      result = Account.find_by(slug: "' OR '1'='1")

      expect(result).to be_nil
      expect(Account.count).to eq(1)
    end
  end

  describe "User email SQL injection" do
    it "prevents SQL injection via email search" do
      create(:user, email: "test@example.com")

      # Attempt SQL injection
      malicious_email = "' OR '1'='1' --"
      result = User.where(email: malicious_email).first

      expect(result).to be_nil
    end

    it "safely handles quotes in user input" do
      email_with_quote = "test'user@example.com"
      user = build(:user, email: email_with_quote)

      # Should fail validation (invalid format) not cause SQL error
      expect { user.valid? }.not_to raise_error
    end
  end

  describe "Workspace description SQL injection" do
    it "prevents SQL injection via text fields" do
      workspace = create(:workspace, account: account)
      initial_count = Workspace.count

      # Attempt injection via description
      workspace.description = "'; DELETE FROM workspaces WHERE '1'='1"

      expect { workspace.save! }.not_to raise_error
      expect(Workspace.count).to eq(initial_count) # No deletion should occur
      expect(workspace.reload.description).to eq("'; DELETE FROM workspaces WHERE '1'='1")
    end
  end

  describe "Raw SQL protection" do
    it "uses parameterized queries for user input" do
      user_input = "'; DROP TABLE users; --"

      # This should use parameterized query
      expect do
        Account.where("slug = ?", user_input).to_a
      end.not_to raise_error

      expect(Account.connection.table_exists?("accounts")).to be true
    end
  end
end
