# frozen_string_literal: true

require "rails_helper"

# SECURITY: Tests for server-side validation bypass attempts
RSpec.describe "Server-side Validation Security", type: :model do
  describe "User validation" do
    let(:user) { build(:user) }

    it "prevents excessively long first names" do
      user.first_name = "a" * 101
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include("is too long (maximum is 100 characters)")
    end

    it "prevents excessively long last names" do
      user.last_name = "a" * 101
      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to include("is too long (maximum is 100 characters)")
    end

    it "prevents invalid avatar URLs" do
      user.avatar_url = "javascript:alert('xss')"
      expect(user).not_to be_valid
      expect(user.errors[:avatar_url]).to include("must be a valid URL")
    end

    it "prevents data URI in avatar_url" do
      user.avatar_url = "data:text/html,<script>alert('xss')</script>"
      expect(user).not_to be_valid
    end

    it "allows valid HTTP URLs in avatar_url" do
      user.avatar_url = "https://example.com/avatar.png"
      expect(user).to be_valid
    end
  end

  describe "Account validation" do
    let(:account) { build(:account) }

    it "prevents names shorter than 2 characters" do
      account.name = "A"
      expect(account).not_to be_valid
      expect(account.errors[:name]).to include("is too short (minimum is 2 characters)")
    end

    it "prevents names longer than 100 characters" do
      account.name = "a" * 101
      expect(account).not_to be_valid
      expect(account.errors[:name]).to include("is too long (maximum is 100 characters)")
    end

    it "prevents slugs with special characters" do
      account.slug = "test@account!"
      expect(account).not_to be_valid
      expect(account.errors[:slug]).to include("must contain only lowercase letters, numbers, and hyphens")
    end

    it "prevents slugs shorter than 2 characters" do
      account.slug = "a"
      expect(account).not_to be_valid
      expect(account.errors[:slug]).to include("is too short (minimum is 2 characters)")
    end

    it "prevents invalid billing email format" do
      account.billing_email = "not-an-email"
      expect(account).not_to be_valid
      expect(account.errors[:billing_email]).to include("must be a valid email")
    end
  end

  describe "Workspace validation" do
    let(:workspace) { build(:workspace) }

    it "prevents descriptions longer than 1000 characters" do
      workspace.description = "a" * 1001
      expect(workspace).not_to be_valid
      expect(workspace.errors[:description]).to include("is too long (maximum is 1000 characters)")
    end

    it "prevents slug injection attacks" do
      workspace.slug = "../../../etc/passwd"
      expect(workspace).not_to be_valid
    end

    it "raises error on null bytes in slug" do
      # Null bytes cause ArgumentError in Ruby strings, which is good security
      expect do
        workspace.slug = "test\x00slug"
        workspace.valid?
      end.to raise_error(ArgumentError, /null byte/)
    end
  end
end
