# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tenant scoping guard" do
  before(:all) do
    Rails.application.eager_load! unless Rails.application.config.eager_load
  end

  it "ensures models with account_id include TenantScoped" do
    models_with_account = ActiveRecord::Base.descendants.select do |model|
      next if model.abstract_class?
      next unless model.table_exists?

      model.column_names.include?("account_id")
    end

    exemptions = [Account]
    offenders = models_with_account.reject do |model|
      model.in?(exemptions) || model < TenantScoped
    end

    expect(offenders).to be_empty,
      "Add TenantScoped to: #{offenders.map(&:name).sort.join(", ")}"
  end
end
