# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  # Test mailer to verify ApplicationMailer behavior
  # rubocop:disable Lint/ConstantDefinitionInBlock
  class TestMailer < ApplicationMailer
    # Set view path to spec fixtures
    self.view_paths = [Rails.root.join("spec/fixtures/mailers")]

    # Expose @account for testing
    attr_reader :account_for_test

    def test_email(recipient)
      @recipient = recipient
      # Store @account in a test-accessible variable
      @account_for_test = @account
      mail(to: recipient, subject: "Test Email")
    end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock

  let(:user) { create(:user) }
  let(:account) { create(:account, billing_email: "billing@testaccount.com") }

  # Use around hook to ensure Current is reset even if tests fail
  around do |example|
    Current.reset
    example.run
  ensure
    Current.reset
  end

  describe "tenant context preservation" do
    context "when Current.account is set" do
      before do
        Current.account = account
      end

      it "sets @account instance variable for template access" do
        # Verify template has access to @account by checking the mailer instance
        mailer = TestMailer.new
        mailer.process(:test_email, user.email)
        expect(mailer.account_for_test).to eq(account)
      end

      it "uses tenant-specific from address when billing_email is present" do
        mail = TestMailer.test_email(user.email)
        expect(mail.from).to include(account.billing_email)
      end

      it "includes account_id in default_url_options" do
        mailer_instance = TestMailer.new
        url_options = mailer_instance.send(:default_url_options)
        expect(url_options[:account_id]).to eq(account.slug)
      end

      it "generates URLs with account context" do
        # Current.account already set by before block
        mailer_instance = TestMailer.new
        url_options = mailer_instance.send(:default_url_options)
        expect(url_options).to include(account_id: account.slug)
      end
    end

    context "when Current.account is not set" do
      # Explicitly reset in before block to ensure clean state
      before do
        Current.reset
        Current.account = nil
      end

      it "uses default from address" do
        # Verify Current.account is nil
        expect(Current.account).to be_nil
        mail = TestMailer.test_email(user.email)
        expect(mail.from).to include("noreply@example.com")
      end

      it "does not include account_id in URL options" do
        mailer_instance = TestMailer.new
        url_options = mailer_instance.send(:default_url_options)
        expect(url_options[:account_id]).to be_nil
      end

      it "sets @account to nil" do
        # Verify Current.account is nil
        expect(Current.account).to be_nil
        mailer = TestMailer.new
        mailer.process(:test_email, user.email)
        expect(mailer.account_for_test).to be_nil
      end
    end

    context "when account has no billing_email" do
      let(:account_without_email) { create(:account, billing_email: nil) }

      before do
        Current.account = account_without_email
      end

      it "falls back to default from address" do
        mail = TestMailer.test_email(user.email)
        expect(mail.from).to include("noreply@example.com")
      end

      it "still sets @account for template access" do
        mailer = TestMailer.new
        mailer.process(:test_email, user.email)
        expect(mailer.account_for_test).to eq(account_without_email)
      end

      it "still includes account_id in URL options" do
        mailer_instance = TestMailer.new
        url_options = mailer_instance.send(:default_url_options)
        expect(url_options[:account_id]).to eq(account_without_email.slug)
      end
    end
  end

  describe "integration with background jobs" do
    let(:account) { create(:account, billing_email: "jobs@background.com") }

    it "maintains tenant context when called from job" do
      # Simulate job context where Current.account is set
      Current.account = account

      mail = TestMailer.test_email(user.email)
      expect(mail.from).to include("jobs@background.com")

      # Also verify @account is set
      mailer = TestMailer.new
      mailer.process(:test_email, user.email)
      expect(mailer.account_for_test).to eq(account)
    end

    it "generates correct URLs in job context" do
      Current.account = account

      mailer_instance = TestMailer.new
      url_options = mailer_instance.send(:default_url_options)

      expect(url_options[:account_id]).to eq(account.slug)
    end
  end

  describe "from address selection" do
    context "with billing_email present" do
      let(:account) { create(:account, billing_email: "custom@tenant.com") }

      before do
        Current.account = account
      end

      it "uses billing_email as from address" do
        mail = TestMailer.test_email(user.email)
        expect(mail.from).to eq(["custom@tenant.com"])
      end
    end

    context "with empty billing_email" do
      let(:account) { create(:account, billing_email: "") }

      before do
        Current.account = account
      end

      it "uses default from address" do
        mail = TestMailer.test_email(user.email)
        expect(mail.from).to eq(["noreply@example.com"])
      end
    end

    context "without Current.account" do
      it "uses default from address" do
        mail = TestMailer.test_email(user.email)
        expect(mail.from).to eq(["noreply@example.com"])
      end
    end
  end
end
