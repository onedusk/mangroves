# frozen_string_literal: true

require "rails_helper"
require "securerandom"

RSpec.describe TenantScoped do
  subject(:model_class) { Workspace }

  around do |example|
    Current.reset
    example.run
    Current.reset
  end

  let(:primary_account) { create(:account) }
  let(:secondary_account) { create(:account) }

  def build_workspace_for(_account)
    model_class.new(name: "Workspace #{SecureRandom.hex(4)}")
  end

  it "adds an account association" do
    association = model_class.reflect_on_association(:account)

    expect(association).to be_present
    expect(association.macro).to eq(:belongs_to)
  end

  it "scopes queries to Current.account" do
    Current.account = primary_account
    in_scope = build_workspace_for(primary_account)
    in_scope.save!

    Current.account = secondary_account
    build_workspace_for(secondary_account).save!

    Current.account = primary_account
    expect(model_class.all).to contain_exactly(in_scope)
  end

  it "auto-assigns Current.account on create" do
    Current.account = primary_account
    record = build_workspace_for(primary_account)

    expect { record.save! }.to change(record, :account).from(nil).to(primary_account)
  end

  it "raises an error when Current.account is missing" do
    record = build_workspace_for(primary_account)

    expect { record.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "provides an unscoped_all helper" do
    Current.account = primary_account
    in_scope = build_workspace_for(primary_account)
    in_scope.save!

    Current.account = secondary_account
    out_of_scope = build_workspace_for(secondary_account)
    out_of_scope.save!

    Current.account = primary_account
    expect(model_class.unscoped_all).to contain_exactly(in_scope, out_of_scope)
  end
end
