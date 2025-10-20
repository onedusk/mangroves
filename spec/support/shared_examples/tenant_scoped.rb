# frozen_string_literal: true

require "securerandom"

RSpec.shared_examples "tenant scoped model" do
  around do |example|
    Current.reset
    example.run
    Current.reset
  end

  let(:primary_account) { create(:account) }
  let(:secondary_account) { create(:account) }

  def build_tenant_record_for(_account)
    raise "define `build_tenant_record_for(account)` in the including spec"
  end

  it "scopes queries to Current.account" do
    Current.account = primary_account
    record_in_scope = build_tenant_record_for(primary_account)
    record_in_scope.save!

    Current.account = secondary_account
    build_tenant_record_for(secondary_account).save!

    Current.account = primary_account
    expect(described_class.all).to contain_exactly(record_in_scope)
  end

  it "auto-assigns Current.account on create" do
    Current.account = primary_account
    record = build_tenant_record_for(primary_account)

    expect { record.save! }.to change(record, :account).from(nil).to(primary_account)
  end

  it "raises an error when Current.account is missing" do
    record = build_tenant_record_for(primary_account)

    expect { record.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "allows bypassing scopes with unscoped_all" do
    Current.account = primary_account
    in_scope = build_tenant_record_for(primary_account)
    in_scope.save!

    Current.account = secondary_account
    out_of_scope = build_tenant_record_for(secondary_account)
    out_of_scope.save!

    Current.account = primary_account
    expect(described_class.unscoped_all).to contain_exactly(in_scope, out_of_scope)
  end
end
