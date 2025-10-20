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
class Workspace < ApplicationRecord
  include TenantScoped # Auto-assigns and scopes records to Current.account

  has_paper_trail on: [:update, :destroy],
    meta: {account_id: :account_id}

  belongs_to :account

  has_many :teams, dependent: :destroy
  has_many :workspace_memberships, dependent: :destroy
  has_many :users, through: :workspace_memberships

  enum :status, {active: 0, archived: 1, suspended: 2}

  validates :name, presence: true
  validates :slug,
    presence: true,
    uniqueness: {scope: :account_id},
    format: {
      with: /\A[a-z0-9][a-z0-9-]*[a-z0-9]\z/,
      message: "must contain only lowercase letters, numbers, and hyphens"
    }

  before_validation :generate_slug, on: :create
  before_validation :set_defaults, on: :create

  scope :active, -> { where(status: :active) }

  def to_param
    slug
  end

  private

  def generate_slug
    return if slug.present?

    base_slug = name.parameterize
    self.slug = base_slug
    counter = 1
    while account.workspaces.exists?(slug:)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end

  def set_defaults
    self.status ||= :active
    self.settings ||= {}
    self.metadata ||= {}
  end
end
