# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  # Tenant Context Preservation
  #
  # Background jobs need to preserve tenant context so they operate within the correct
  # account scope. When enqueuing jobs, pass account_id as an argument:
  #
  #   MyJob.perform_later(account_id: Current.account.id, other: params)
  #
  # This callback automatically restores Current.account for the duration of job execution
  # and ensures proper cleanup when the job completes or fails.
  around_perform do |job, block|
    # Extract account_id from job arguments (handles both keyword args and hash args)
    account_id = if job.arguments.last.is_a?(Hash)
                   job.arguments.last[:account_id] || job.arguments.last["account_id"]
                 end

    if account_id
      account = Account.find(account_id)
      Current.set(account:) { block.call }
    else
      # No account_id provided - execute without tenant context
      block.call
    end
  end
end
