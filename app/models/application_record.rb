# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  self.implicit_order_column = :created_at

  before_create :generate_uuid

  private

  def generate_uuid
    self.id ||= SecureRandom.uuid if self.class.columns_hash["id"]&.type == :uuid
  end
end
