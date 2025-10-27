# frozen_string_literal: true

# == Schema Information
#
# Table name: account_memberships
#
#  id            :uuid             not null, primary key
#  accepted_at   :datetime
#  invited_at    :datetime
#  metadata      :jsonb
#  role          :integer          default("viewer"), not null
#  status        :integer          default("pending"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  account_id    :uuid             not null
#  invited_by_id :uuid
#  user_id       :uuid             not null
#
# Indexes
#
#  index_account_memberships_on_account_id              (account_id)
#  index_account_memberships_on_account_id_and_user_id  (account_id,user_id) UNIQUE
#  index_account_memberships_on_invited_by_id           (invited_by_id)
#  index_account_memberships_on_role                    (role)
#  index_account_memberships_on_status                  (status)
#  index_account_memberships_on_user_id                 (user_id)
#  index_account_memberships_on_user_id_and_account_id  (user_id,account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (user_id => users.id)
#
class AccountMembership < ApplicationRecord
  include TenantScoped # Restrict membership queries to Current.account

  belongs_to :account
  belongs_to :user
  belongs_to :invited_by, class_name: "User", optional: true

  enum :role, {viewer: 0, member: 1, admin: 2, owner: 3}
  enum :status, {pending: 0, active: 1, suspended: 2, declined: 3}

  validates :user_id, uniqueness: {scope: :account_id}

  before_validation :set_defaults, on: :create

  scope :active, -> { where(status: :active) }
  scope :pending, -> { where(status: :pending) }
  scope :admins, -> { where(role: %i[admin owner]) }

  def accept!
    update!(status: :active, accepted_at: Time.current)
  end

  def decline!
    update!(status: :declined)
  end

  private

  def set_defaults
    self.role ||= :member
    self.status ||= :pending
    self.invited_at ||= Time.current
    self.metadata ||= {}
  end
end
