# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkspaceSwitcherComponent, type: :component do
  let(:account) { create(:account, name: "Test Account") }
  let(:workspace1) { create(:workspace, account: account, name: "Production") }
  let(:workspace2) { create(:workspace, account: account, name: "Staging") }
  let(:user) { create(:user) }
  let!(:account_membership) { create(:account_membership, user: user, account: account, status: :active) }
  let!(:workspace_membership1) do
    create(:workspace_membership, user: user, workspace: workspace1, status: :active)
  end
  let!(:workspace_membership2) do
    create(:workspace_membership, user: user, workspace: workspace2, status: :active)
  end

  before do
    # Set current attributes for tenant scoping
    allow(Current).to receive(:account).and_return(account)
    allow(Current).to receive(:workspace).and_return(workspace1)
    user.update!(current_workspace: workspace1)
  end

  describe "#template" do
    it "renders workspace switcher with current workspace" do
      component = described_class.new(current_user: user, current_workspace: workspace1)
      rendered = component.call

      expect(rendered).to include("Production")
    end

    it "includes dropdown controller" do
      component = described_class.new(current_user: user, current_workspace: workspace1)
      rendered = component.call

      expect(rendered).to include('data-controller="dropdown"')
    end

    it "lists all accessible workspaces" do
      component = described_class.new(current_user: user, current_workspace: workspace1)
      rendered = component.call

      expect(rendered).to include("Production")
      expect(rendered).to include("Staging")
    end

    it "groups workspaces by account" do
      component = described_class.new(current_user: user, current_workspace: workspace1)
      rendered = component.call

      expect(rendered).to include("Test Account")
    end

    it "includes CSRF token for workspace switching" do
      component = described_class.new(current_user: user, current_workspace: workspace1)
      rendered = component.call

      expect(rendered).to include("authenticity_token")
    end

    it "highlights current workspace" do
      component = described_class.new(current_user: user, current_workspace: workspace1)
      rendered = component.call

      expect(rendered).to include("bg-blue-50").or include("font-semibold")
    end

    it "includes keyboard navigation support" do
      component = described_class.new(current_user: user, current_workspace: workspace1)
      rendered = component.call

      expect(rendered).to include('data-dropdown-keyboard-value="true"')
    end
  end

  describe "tenant isolation" do
    let(:other_account) { create(:account, name: "Other Account") }
    let(:other_workspace) { create(:workspace, account: other_account, name: "Other") }
    let!(:other_workspace_membership) do
      create(:workspace_membership, user: user, workspace: other_workspace, status: :active)
    end
    let!(:other_account_membership) do
      create(:account_membership, user: user, account: other_account, status: :active)
    end

    it "only shows workspaces user has active membership for" do
      component = described_class.new(current_user: user, current_workspace: workspace1)
      rendered = component.call

      expect(rendered).to include("Production")
      expect(rendered).to include("Staging")
      expect(rendered).to include("Other")
    end

    it "does not show workspaces from accounts without active membership" do
      account_membership.update!(status: :inactive)

      component = described_class.new(current_user: user, current_workspace: other_workspace)
      rendered = component.call

      expect(rendered).not_to include("Production")
      expect(rendered).not_to include("Staging")
      expect(rendered).to include("Other")
    end

    it "verifies user has workspace membership before rendering" do
      workspace_membership2.update!(status: :inactive)

      component = described_class.new(current_user: user, current_workspace: workspace1)
      rendered = component.call

      expect(rendered).to include("Production")
      expect(rendered).not_to include("Staging")
    end
  end

  describe "XSS protection" do
    it "escapes HTML in workspace name" do
      workspace1.update!(name: "<script>alert('XSS')</script>")

      component = described_class.new(current_user: user, current_workspace: workspace1)
      rendered = component.call

      expect(rendered).not_to include("<script>")
      expect(rendered).to include("&lt;script&gt;")
    end

    it "escapes HTML in account name" do
      account.update!(name: "<img src=x onerror=alert('XSS')>")

      component = described_class.new(current_user: user, current_workspace: workspace1)
      rendered = component.call

      expect(rendered).not_to include("onerror=")
      expect(rendered).to include("&lt;img")
    end
  end
end
