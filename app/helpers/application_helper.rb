# frozen_string_literal: true

module ApplicationHelper
  # SECURITY: URL validation helpers for preventing open redirects and XSS

  # List of allowed domains for URL validation
  ALLOWED_DOMAINS = %w[
    localhost
    127.0.0.1
  ].freeze

  # Validates that a URL is safe and returns sanitized version or nil
  # @param url [String] URL to validate
  # @return [String, nil] Sanitized URL or nil if invalid
  def safe_url(url)
    return nil if url.blank?

    begin
      uri = URI.parse(url.to_s)
      return nil unless %w[http https].include?(uri.scheme)
      return nil unless allowed_domain?(uri.host)

      uri.to_s
    rescue URI::InvalidURIError
      nil
    end
  end

  # Validates URL and raises error if invalid
  # @param url [String] URL to validate
  # @return [Boolean] true if valid
  # @raise [ArgumentError] if URL is invalid
  def validate_url!(url)
    return false if url.blank?

    uri = URI.parse(url.to_s)
    raise ArgumentError, "Invalid URL scheme: #{uri.scheme}" unless %w[http https].include?(uri.scheme)
    raise ArgumentError, "Domain not allowed: #{uri.host}" unless allowed_domain?(uri.host)

    true
  rescue URI::InvalidURIError => e
    raise ArgumentError, "Malformed URL: #{e.message}"
  end

  # Checks if domain is in allowed list or matches current application domain
  # @param domain [String] Domain to check
  # @return [Boolean] true if domain is allowed
  def allowed_domain?(domain)
    return false if domain.blank?

    # Allow current application domain
    return true if domain == request.host

    # Allow configured allowed domains
    ALLOWED_DOMAINS.include?(domain) ||
      Rails.configuration.allowed_redirect_domains&.include?(domain)
  end
end
