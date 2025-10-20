# frozen_string_literal: true

# == Schema Information
#
# Table name: workspaces
#
#  id          :uuid             not null, primary key
#  description :text
#  metadata    :jsonb
#  name        :string           not null
#  settings    :jsonb
#  slug        :string           not null
#  status      :integer          default("active"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :uuid             not null
#
# Indexes
#
#  index_workspaces_on_account_id           (account_id)
#  index_workspaces_on_account_id_and_slug  (account_id,slug) UNIQUE
#  index_workspaces_on_slug                 (slug) UNIQUE
#  index_workspaces_on_status               (status)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
FactoryBot.define do
  factory :workspace do
    account
    sequence(:name) { |n| "Workspace #{n}" }
    sequence(:slug) { |n| "workspace-#{n}" }
    description { "Workspace description" }
    status { :active }
    settings { {} }
    metadata { {} }
  end
end
