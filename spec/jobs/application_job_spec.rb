# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationJob, type: :job do
  # Create a test job class for testing the tenant context pattern
  # Uses class variable to track execution state since instance vars
  # aren't accessible across perform_now boundary
  class TestJob < ApplicationJob # rubocop:disable Lint/ConstantDefinitionInBlock
    cattr_accessor :last_executed_account_id

    def perform(_account_id: nil, **_options)
      self.class.last_executed_account_id = Current.account&.id
    end
  end

  # Create a job that raises an error to test cleanup on failure
  class FailingJob < ApplicationJob # rubocop:disable Lint/ConstantDefinitionInBlock
    def perform(_account_id: nil, **_options)
      raise StandardError, "Intentional test failure"
    end
  end

  let(:account) { create(:account) }

  before do
    # Reset tracked state before each test
    TestJob.last_executed_account_id = nil
  end

  describe "tenant context preservation" do
    context "when account_id is provided as keyword argument" do
      it "restores Current.account from job arguments" do
        # Ensure Current.account is nil before job execution
        expect(Current.account).to be_nil

        # Perform job synchronously with account_id
        TestJob.perform_now(account_id: account.id)

        # Verify Current.account was set during execution by checking what the job saw
        expect(TestJob.last_executed_account_id).to eq(account.id)
      end

      it "resets Current.account after job completes" do
        # Ensure Current.account is nil before
        expect(Current.account).to be_nil

        # Perform job synchronously
        TestJob.perform_now(account_id: account.id)

        # Verify Current.account is reset after job completes
        expect(Current.account).to be_nil
      end
    end

    context "when account_id is provided with other arguments" do
      it "extracts account_id from keyword arguments with other params" do
        TestJob.perform_now(account_id: account.id, other_param: "value")

        expect(TestJob.last_executed_account_id).to eq(account.id)
      end
    end

    context "when no account_id is provided" do
      it "executes job without setting Current.account" do
        TestJob.perform_now

        expect(TestJob.last_executed_account_id).to be_nil
      end
    end

    context "when job raises an error" do
      it "still resets Current.account after failure" do
        # Ensure Current.account is nil before
        expect(Current.account).to be_nil

        # Perform failing job and expect it to raise
        expect do
          FailingJob.perform_now(account_id: account.id)
        end.to raise_error(StandardError, "Intentional test failure")

        # Verify Current.account is reset even after failure
        expect(Current.account).to be_nil
      end
    end

    context "with multiple accounts" do
      let(:account2) { create(:account) }

      it "correctly isolates tenant context between sequential jobs" do
        TestJob.perform_now(account_id: account.id)
        first_execution_account_id = TestJob.last_executed_account_id

        TestJob.perform_now(account_id: account2.id)
        second_execution_account_id = TestJob.last_executed_account_id

        expect(first_execution_account_id).to eq(account.id)
        expect(second_execution_account_id).to eq(account2.id)
        expect(Current.account).to be_nil
      end
    end

    context "when account does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        non_existent_id = SecureRandom.uuid

        expect do
          TestJob.perform_now(account_id: non_existent_id)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "integration with ActiveJob" do
    it "works with perform_later enqueuing" do
      # This tests that the argument structure is preserved through enqueuing
      expect do
        TestJob.perform_later(account_id: account.id)
      end.to have_enqueued_job(TestJob).with(account_id: account.id)
    end
  end
end
