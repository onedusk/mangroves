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
class Team < ApplicationRecord
  include TenantScoped # Enforces default scope + auto-assigns tenant on create

  has_paper_trail on: [:update, :destroy],
    meta: {account_id: :account_id, workspace_id: :workspace_id}

  belongs_to :workspace

  has_many :team_memberships, dependent: :destroy
  has_many :users, through: :team_memberships

  enum :status, {active: 0, archived: 1}

  validates :name, presence: true, length: {minimum: 2, maximum: 100}
  validates :slug,
    presence: true,
    uniqueness: {scope: :workspace_id},
    length: {minimum: 2, maximum: 63},
    format: {
      with: /\A[a-z0-9][a-z0-9-]*[a-z0-9]\z/,
      message: "must contain only lowercase letters, numbers, and hyphens"
    }
  validates :description, length: {maximum: 1000}, allow_blank: true

  before_validation :generate_slug, on: :create
  before_validation :set_defaults, on: :create

  # SECURITY: Strict validation that account must come from Current.account (via TenantScoped)
  # This replaces sync_account_from_workspace which could mask authorization bugs
  validate :account_matches_workspace
  validate :account_matches_current_on_create, on: :create

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
    while workspace.teams.exists?(slug:)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end

  def set_defaults
    self.status ||= :active
    self.settings ||= {}
    self.metadata ||= {}
  end

  def account_matches_workspace
    return if workspace.blank? || account.blank?
    return if workspace.account_id == account_id

    errors.add(:account, "must belong to the same account as workspace")
  end

  def account_matches_current_on_create
    return if Current.account.blank? || account.blank?
    return if account_id == Current.account.id

    # SECURITY: Account must match Current.account (enforced by TenantScoped)
    # This prevents creating teams with the wrong tenant context
    errors.add(:account, "must match Current.account (got #{account_id}, expected #{Current.account.id})")
  end
end
