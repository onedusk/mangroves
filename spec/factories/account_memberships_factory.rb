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
FactoryBot.define do
  factory :account_membership do
    account
    user
    role { :member }
    status { :pending }
    invited_by { nil }
    invited_at { Time.current }
    accepted_at { nil }
    metadata { {} }
  end
end
