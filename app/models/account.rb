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
class Account < ApplicationRecord
  enum :status, {active: 0, suspended: 1, cancelled: 2, archived: 3}
  enum :plan,
    {free: "free", starter: "starter", professional: "professional", enterprise: "enterprise"},
    prefix: true,
    scopes: false

  has_paper_trail on: [:update, :destroy],
    meta: {account_id: :id}

  has_many :workspaces, dependent: :destroy
  has_many :account_memberships, dependent: :destroy
  has_many :users, through: :account_memberships

  belongs_to :owner, class_name: "User", optional: true

  validates :name, presence: true
  validates :slug,
    presence: true,
    uniqueness: true,
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
    while Account.exists?(slug:)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end

  def set_defaults
    self.status ||= :active
    self.plan ||= :free
    self.settings ||= {}
    self.metadata ||= {}
  end
end
