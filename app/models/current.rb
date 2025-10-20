# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :user, :account, :workspace, :request_id

  def user=(user)
    super
    self.account = user&.current_account
    self.workspace = user&.current_workspace
  end
end
