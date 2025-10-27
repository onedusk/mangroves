# frozen_string_literal: true

require "rails_helper"

# SECURITY: Tests for XSS injection prevention
RSpec.describe "XSS Injection Prevention", type: :system do
  let(:user) { create(:user) }
  let(:account) { create(:account, owner: user) }
  let(:workspace) { create(:workspace, account: account) }

  before do
    create(:account_membership, user: user, account: account, role: :owner)
    create(:workspace_membership, user: user, workspace: workspace, role: :owner)
    user.update!(current_workspace: workspace)
    sign_in user
  end

  describe "Account name XSS prevention" do
    it "escapes HTML in account names" do
      account.update!(name: "<script>alert('xss')</script>")
      visit account_path(account)

      # Should display escaped text, not execute script
      expect(page).to have_content("<script>alert('xss')</script>")
      expect(page).to have_no_css("script")
    end

    it "escapes malformed HTML entities" do
      account.update!(name: "&lt;img src=x onerror=alert('xss')&gt;")
      visit account_path(account)

      expect(page).to have_content("&lt;img src=x onerror=alert('xss')&gt;")
    end
  end

  describe "Workspace description XSS prevention" do
    it "sanitizes HTML in descriptions" do
      workspace.update!(description: "<img src=x onerror=alert('xss')>")
      visit account_workspace_path(account, workspace)

      # Should not contain dangerous attributes
      expect(page).to have_no_css("img[onerror]")
    end

    it "prevents javascript: URLs" do
      workspace.update!(description: "<a href='javascript:alert(1)'>Click</a>")
      visit account_workspace_path(account, workspace)

      # Should not have javascript: links
      expect(page).to have_no_link(href: /javascript:/)
    end
  end

  describe "Component XSS prevention" do
    it "escapes user input in SonnerComponent" do
      # Create a toast with XSS attempt
      xss_message = "<script>alert('xss')</script>"

      # This should not execute the script
      component = SonnerComponent.new(message: xss_message)
      rendered = component.call

      expect(rendered).to include(ERB::Util.html_escape(xss_message))
      expect(rendered).not_to include("<script>alert('xss')</script>")
    end
  end
end
