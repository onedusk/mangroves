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
require "rails_helper"
require "securerandom"

RSpec.describe Workspace, type: :model do
  it "includes TenantScoped" do
    expect(described_class.ancestors).to include(TenantScoped)
  end

  it_behaves_like "tenant scoped model" do
    def build_tenant_record_for(_account)
      described_class.new(name: "Workspace #{SecureRandom.hex(4)}")
    end
  end
end
