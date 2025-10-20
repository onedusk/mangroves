# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id           :uuid             not null, primary key
#  description  :text
#  account_id   :uuid             not null
#  metadata     :jsonb
#  name         :string           not null
#  settings     :jsonb
#  slug         :string           not null
#  status       :integer          default("active"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  workspace_id :uuid             not null
#
# Indexes
#
#  index_teams_on_account_id             (account_id)
#  index_teams_on_account_id_and_slug    (account_id,slug) UNIQUE
#  index_teams_on_status                 (status)
#  index_teams_on_workspace_id           (workspace_id)
#  index_teams_on_workspace_id_and_slug  (workspace_id,slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
FactoryBot.define do
  factory :team do
    workspace
    sequence(:name) { |n| "Team #{n}" }
    sequence(:slug) { |n| "team-#{n}" }
    description { "Team description" }
    status { :active }
    settings { {} }
    metadata { {} }

    after(:build) do |team|
      team.account ||= team.workspace&.account
    end
  end
end
