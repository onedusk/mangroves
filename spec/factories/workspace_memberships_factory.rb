# frozen_string_literal: true

# == Schema Information
#
# Table name: workspace_memberships
#
#  id            :uuid             not null, primary key
#  accepted_at   :datetime
#  invited_at    :datetime
#  metadata      :jsonb
#  role          :integer          default("viewer"), not null
#  status        :integer          default("pending"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invited_by_id :uuid
#  user_id       :uuid             not null
#  workspace_id  :uuid             not null
#
# Indexes
#
#  index_workspace_memberships_on_invited_by_id             (invited_by_id)
#  index_workspace_memberships_on_role                      (role)
#  index_workspace_memberships_on_status                    (status)
#  index_workspace_memberships_on_user_id                   (user_id)
#  index_workspace_memberships_on_user_id_and_workspace_id  (user_id,workspace_id)
#  index_workspace_memberships_on_workspace_id              (workspace_id)
#  index_workspace_memberships_on_workspace_id_and_user_id  (workspace_id,user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#
FactoryBot.define do
  factory :workspace_membership do
    workspace
    user
    role { :member }
    status { :pending }
    invited_by { nil }
    invited_at { Time.current }
    accepted_at { nil }
    metadata { {} }
  end
end
