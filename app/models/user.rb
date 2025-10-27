# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  avatar_url             :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  first_name             :string
#  last_name              :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  metadata               :jsonb
#  phone                  :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer          default("member"), not null
#  settings               :jsonb
#  sign_in_count          :integer          default(0), not null
#  status                 :integer          default("active"), not null
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  current_workspace_id   :uuid
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_current_workspace_id  (current_workspace_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_role                  (role)
#  index_users_on_status                (status)
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
class User < ApplicationRecord
  devise :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :validatable,
    :confirmable,
    :lockable,
    :trackable

  has_paper_trail on: [:update],
    ignore: [:last_sign_in_at, :current_sign_in_at, :sign_in_count, :current_sign_in_ip, :last_sign_in_ip],
    meta: {account_id: proc { Current.account&.id }}

  has_many :account_memberships, dependent: :destroy
  has_many :accounts, through: :account_memberships

  has_many :workspace_memberships, dependent: :destroy
  has_many :workspaces, through: :workspace_memberships

  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships

  has_many :owned_accounts, class_name: "Account", foreign_key: :owner_id, dependent: :nullify

  belongs_to :current_workspace, class_name: "Workspace", optional: true

  enum :role, {member: 0, admin: 1, super_admin: 2}
  enum :status, {active: 0, inactive: 1, suspended: 2}

  validates :first_name, presence: true, length: {maximum: 100}
  validates :last_name, presence: true, length: {maximum: 100}
  validates :phone, length: {maximum: 20}, allow_blank: true
  validates :avatar_url,
    format: {with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL"},
    allow_blank: true

  before_validation :set_defaults, on: :create

  scope :active, -> { where(status: :active) }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def display_name
    full_name.presence || email
  end

  def initials
    "#{first_name&.first}#{last_name&.first}".upcase
  end

  def current_account
    current_workspace&.account
  end

  def accessible_accounts
    accounts.active.distinct
  end

  def accessible_workspaces
    workspaces.active.includes(:account).distinct
  end

  private

  def set_defaults
    self.status ||= :active
    self.role ||= :member
    self.settings ||= {}
    self.metadata ||= {}
  end
end
