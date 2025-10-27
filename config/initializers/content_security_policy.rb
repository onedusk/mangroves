# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# SECURITY: Content Security Policy configuration
# Prevents XSS attacks by restricting sources of scripts, styles, and other resources
# See: https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    # Default: Only allow resources from same origin and HTTPS
    policy.default_src :self, :https

    # Fonts: Allow self, HTTPS, and data URIs (for inline fonts)
    policy.font_src :self, :https, :data

    # Images: Allow self, HTTPS, and data URIs (for inline images/avatars)
    policy.img_src :self, :https, :data, :blob

    # Objects: Disallow all plugins (Flash, Java, etc.)
    policy.object_src :none

    # Scripts: Allow self and use nonces for inline scripts
    # NOTE: Nonces prevent inline script execution unless explicitly allowed
    policy.script_src :self

    # Styles: Allow self and use nonces for inline styles
    policy.style_src :self

    # Connect: Allow same origin for AJAX/fetch/WebSocket
    policy.connect_src :self

    # Frames: Disallow embedding in iframes (prevents clickjacking)
    policy.frame_ancestors :none

    # Base URI: Restrict base tag to prevent base tag injection
    policy.base_uri :self

    # Forms: Only allow form submissions to same origin
    policy.form_action :self

    # SECURITY: Upgrade insecure requests to HTTPS in production
    policy.upgrade_insecure_requests if Rails.env.production?

    # NOTE: Uncomment to report violations to an endpoint
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # SECURITY: Generate nonces for inline scripts and styles
  # This allows importmap and inline content while blocking arbitrary scripts
  config.content_security_policy_nonce_generator = lambda { |_request|
    # Use session ID as nonce base (unique per session)
    SecureRandom.base64(16)
  }

  # Apply nonces to script and style tags
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # SECURITY: Start in report-only mode, then enforce after testing
  # Uncomment to enable enforcement (recommended for production)
  # config.content_security_policy_report_only = false
end
