# frozen_string_literal: true

require "rails_helper"

# SECURITY: Tests for open redirect prevention
RSpec.describe "Open Redirect Prevention", type: :request do
  let(:user) { create(:user) }
  let(:account) { create(:account, owner: user) }
  let(:workspace) { create(:workspace, account: account) }

  before do
    create(:account_membership, user: user, account: account, role: :owner)
    create(:workspace_membership, user: user, workspace: workspace, role: :owner)
    user.update!(current_workspace: workspace)
    sign_in user
  end

  describe "Account switch redirect validation" do
    it "prevents redirect to external URLs" do
      # Attempt to redirect to external site
      malicious_account = create(:account, owner: user)
      create(:account_membership, user: user, account: malicious_account, role: :owner)

      post switch_account_path(malicious_account), params: {redirect_to: "https://evil.com"}

      # Should redirect to account page, not external site
      expect(response).to redirect_to(account_path(malicious_account))
    end

    it "prevents javascript: URLs in redirects" do
      post switch_account_path(account), params: {redirect_to: "javascript:alert(1)"}

      expect(response).to redirect_to(account_path(account))
      expect(response.location).not_to include("javascript:")
    end
  end

  describe "ApplicationHelper URL validation" do
    include ApplicationHelper

    it "rejects javascript: URLs" do
      url = "javascript:alert('xss')"
      expect(safe_url(url)).to be_nil
    end

    it "rejects data: URLs" do
      url = "data:text/html,<script>alert('xss')</script>"
      expect(safe_url(url)).to be_nil
    end

    it "rejects file: URLs" do
      url = "file:///etc/passwd"
      expect(safe_url(url)).to be_nil
    end

    it "allows http URLs to localhost" do
      url = "http://localhost:3000/accounts"

      # Mock request.host to return localhost
      allow(self).to receive(:request).and_return(double(host: "localhost"))

      expect(safe_url(url)).to eq("http://localhost:3000/accounts")
    end

    it "rejects external domains by default" do
      url = "https://evil.com/phishing"

      # Mock request.host
      allow(self).to receive(:request).and_return(double(host: "example.com"))

      expect(safe_url(url)).to be_nil
    end

    it "allows configured allowed domains" do
      url = "https://example.com/safe"

      # Mock request.host and config
      allow(self).to receive(:request).and_return(double(host: "example.com"))

      expect(safe_url(url)).to eq("https://example.com/safe")
    end
  end

  describe "validate_url! helper" do
    include ApplicationHelper

    it "raises ArgumentError for invalid schemes" do
      allow(self).to receive(:request).and_return(double(host: "localhost"))

      expect do
        validate_url!("javascript:alert(1)")
      end.to raise_error(ArgumentError, /Invalid URL scheme/)
    end

    it "raises ArgumentError for disallowed domains" do
      allow(self).to receive(:request).and_return(double(host: "localhost"))

      expect do
        validate_url!("https://evil.com")
      end.to raise_error(ArgumentError, /Domain not allowed/)
    end

    it "accepts valid URLs" do
      allow(self).to receive(:request).and_return(double(host: "localhost"))

      expect(validate_url!("http://localhost/accounts")).to be true
    end
  end
end
