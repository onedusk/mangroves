# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id                   :uuid             not null, primary key
#  billing_email        :string
#  metadata             :jsonb
#  name                 :string           not null
#  plan                 :string           default("free")
#  settings             :jsonb
#  slug                 :string           not null
#  status               :integer          default("active"), not null
#  subscription_ends_at :datetime
#  trial_ends_at        :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  owner_id             :uuid
#
# Indexes
#
#  index_accounts_on_owner_id  (owner_id)
#  index_accounts_on_slug      (slug) UNIQUE
#  index_accounts_on_status    (status)
#
FactoryBot.define do
  factory :account do
    sequence(:name) { |n| "Account #{n}" }
    sequence(:slug) { |n| "account-#{n}" }
    plan { "free" }
    status { :active }
    billing_email { "billing@example.com" }
    trial_ends_at { 14.days.from_now }
    subscription_ends_at { nil }
    settings { {} }
    metadata { {} }

    transient do
      owner { nil }
    end

    after(:build) do |account, evaluator|
      account.owner ||= evaluator.owner
    end
  end
end
