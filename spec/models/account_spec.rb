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
require "rails_helper"

RSpec.describe Account, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
