# frozen_string_literal: true

# Base component class providing XSS protection and sanitization helpers
# All application components should inherit from this class
class ApplicationComponent < Phlex::HTML
  include ERB::Util

  private

  # Sanitize text content for safe display
  # Escapes HTML entities to prevent XSS
  # @param text [String] The text to sanitize
  # @return [String] Sanitized text safe for display
  def sanitize_text(text)
    return "" if text.nil?

    html_escape(text.to_s)
  end

  # Sanitize HTML content while allowing safe tags
  # Uses Rails ActionView sanitize helper for safe HTML rendering
  # @param html [String] The HTML to sanitize
  # @return [String] Sanitized HTML safe for display
  def sanitize_html(html)
    return "" if html.nil?

    # Use Rails sanitize helper if available, otherwise escape all
    if defined?(ActionController::Base)
      ActionController::Base.helpers.sanitize(html)
    else
      html_escape(html.to_s)
    end
  end

  # Sanitize and encode URL for safe use in href/src attributes
  # Prevents javascript: and data: URL injection attacks
  # @param url [String] The URL to sanitize
  # @return [String, nil] Sanitized URL or nil if dangerous
  def safe_url(url)
    return nil if url.nil?

    url_string = url.to_s.strip

    # Block dangerous URL schemes
    dangerous_schemes = %w[javascript data vbscript file]
    return nil if dangerous_schemes.any? { |scheme| url_string.downcase.start_with?("#{scheme}:") }

    # URL encode the URL to prevent injection
    url_encode(url_string)
  end

  # Render user-controlled text content safely
  # Convenience method that uses Phlex's plain method with sanitization
  # @param text [String] The text to render
  def safe_text(text)
    plain sanitize_text(text) if text
  end

  # Render user-controlled HTML content safely
  # Convenience method that renders sanitized HTML
  # @param html [String] The HTML to render
  def safe_html(html)
    return if html.nil?

    unsafe_raw sanitize_html(html)
  end

  # Render Proc content safely by capturing its output
  # @param proc_content [Proc] The proc to execute
  def safe_proc(proc_content)
    return unless proc_content.is_a?(Proc)

    # Execute the proc and capture output safely
    # The proc should use plain/text methods internally for safety
    proc_content.call
  end

  # SECURITY: Component parameter validation helpers

  # Validates enum values
  # @param value [Symbol, String] Value to validate
  # @param allowed [Array<Symbol, String>] Allowed values
  # @param param_name [String] Parameter name for error messages
  # @return [Symbol] Validated value
  # @raise [ArgumentError] if value is not in allowed list
  def validate_enum(value, allowed:, param_name: "value")
    value = value.to_sym if value.is_a?(String)
    return value if allowed.include?(value)

    raise ArgumentError,
      "Invalid #{param_name}: #{value.inspect}. Must be one of: #{allowed.join(", ")}"
  end

  # Validates numeric ranges
  # @param value [Numeric] Value to validate
  # @param min [Numeric, nil] Minimum value (inclusive)
  # @param max [Numeric, nil] Maximum value (inclusive)
  # @param param_name [String] Parameter name for error messages
  # @return [Numeric] Validated value
  # @raise [ArgumentError] if value is out of range
  def validate_range(value, min: nil, max: nil, param_name: "value")
    raise ArgumentError, "#{param_name} must be a number" unless value.is_a?(Numeric)
    raise ArgumentError, "#{param_name} must be >= #{min}" if min && value < min
    raise ArgumentError, "#{param_name} must be <= #{max}" if max && value > max

    value
  end

  # Validates required parameters
  # @param value [Object] Value to validate
  # @param param_name [String] Parameter name for error messages
  # @return [Object] Validated value
  # @raise [ArgumentError] if value is nil or blank
  def validate_required(value, param_name: "value")
    return value unless value.nil? || (value.respond_to?(:blank?) && value.blank?)

    raise ArgumentError, "#{param_name} is required"
  end

  # Validates string length
  # @param value [String] Value to validate
  # @param min [Integer, nil] Minimum length
  # @param max [Integer, nil] Maximum length
  # @param param_name [String] Parameter name for error messages
  # @return [String] Validated value
  # @raise [ArgumentError] if length is invalid
  def validate_length(value, min: nil, max: nil, param_name: "value")
    return value if value.nil?

    unless value.respond_to?(:length)
      raise ArgumentError, "#{param_name} must respond to :length"
    end

    length = value.length
    raise ArgumentError, "#{param_name} length must be >= #{min}" if min && length < min
    raise ArgumentError, "#{param_name} length must be <= #{max}" if max && length > max

    value
  end
end
