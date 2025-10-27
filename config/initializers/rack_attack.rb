# frozen_string_literal: true

# SECURITY: Rack::Attack configuration for rate limiting and abuse prevention
# See https://github.com/rack/rack-attack for more configuration options

class Rack::Attack
  # Use Rails.cache for storing rate limit data (leverages Solid Cache)
  if Rails.env.production?
    Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
      url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1")
    )
  end

  # Throttle configuration
  # NOTE: Customize these limits based on your application requirements

  # Throttle onboarding and account creation (5 attempts per hour per IP)
  throttle("onboarding/ip", limit: 5, period: 1.hour) do |req|
    if req.path == "/onboarding" && req.post?
      req.ip
    end
  end

  # Throttle account creation by IP
  throttle("accounts/create/ip", limit: 5, period: 1.hour) do |req|
    if req.path == "/accounts" && req.post?
      req.ip
    end
  end

  # Throttle login attempts (5 attempts per 20 minutes per email)
  throttle("login/email", limit: 5, period: 20.minutes) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params["user"]&.dig("email")&.to_s&.downcase&.presence
    end
  end

  # Throttle login attempts by IP (10 attempts per 20 minutes)
  throttle("login/ip", limit: 10, period: 20.minutes) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.ip
    end
  end

  # Throttle password reset requests (3 per hour per IP)
  throttle("password_reset/ip", limit: 3, period: 1.hour) do |req|
    if req.path == "/users/password" && req.post?
      req.ip
    end
  end

  # General API throttling (100 requests per 5 minutes per IP)
  throttle("api/ip", limit: 100, period: 5.minutes) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  # Block suspicious requests
  # WARNING: Customize these blocklists based on your security requirements

  # Block requests with suspicious User-Agent headers
  blocklist("block suspicious user agents") do |req|
    # Block blank user agents or known bot patterns
    req.user_agent.blank? || req.user_agent =~ /curl|wget|python|scrapy|bot/i
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    retry_after = (env["rack.attack.match_data"] || {})[:period]
    [
      429,
      {
        "Content-Type" => "text/html",
        "Retry-After" => retry_after.to_s
      },
      ["<html><body><h1>Too Many Requests</h1><p>Please try again later.</p></body></html>"]
    ]
  end

  # Custom response for blocked requests
  self.blocklisted_responder = lambda do |_env|
    [
      403,
      {"Content-Type" => "text/html"},
      ["<html><body><h1>Forbidden</h1><p>Your request has been blocked.</p></body></html>"]
    ]
  end

  # ActiveSupport::Notification for logging
  ActiveSupport::Notifications.subscribe("rack.attack") do |name, _start, _finish, _request_id, payload|
    req = payload[:request]
    Rails.logger.warn(
      "[Rack::Attack] #{name} - IP: #{req.ip} - Path: #{req.path} - Discriminator: #{payload[:discriminator]}"
    )
  end
end
