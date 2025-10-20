# frozen_string_literal: true

# == Schema Information
#
# Table name: team_memberships
#
#  id            :uuid             not null, primary key
#  accepted_at   :datetime
#  invited_at    :datetime
#  metadata      :jsonb
#  role          :integer          default("member"), not null
#  status        :integer          default("pending"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invited_by_id :uuid
#  team_id       :uuid             not null
#  user_id       :uuid             not null
#
# Indexes
#
#  index_team_memberships_on_invited_by_id        (invited_by_id)
#  index_team_memberships_on_role                 (role)
#  index_team_memberships_on_status               (status)
#  index_team_memberships_on_team_id              (team_id)
#  index_team_memberships_on_team_id_and_user_id  (team_id,user_id) UNIQUE
#  index_team_memberships_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :team_membership do
    team
    user
    role { :member }
    status { :pending }
    invited_by { nil }
    invited_at { Time.current }
    accepted_at { nil }
    metadata { {} }
  end
end
