# frozen_string_literal: true

require "rails_helper"

# SECURITY: Tests for rate limiting via Rack::Attack
RSpec.describe "Rate Limiting", type: :request do
  let(:user) { create(:user) }

  before do
    # Clear Rack::Attack cache before each test
    Rack::Attack.cache.store.clear if Rack::Attack.cache.store.respond_to?(:clear)
  end

  describe "Onboarding rate limiting" do
    it "allows up to 5 onboarding attempts per hour" do
      sign_in user

      # Should allow 5 requests
      5.times do
        post onboarding_path, params: {account: {name: "Test Account"}}
        expect(response.status).not_to eq(429)
      end
    end

    it "throttles after 5 attempts per hour" do
      sign_in user

      # Make 5 allowed requests
      5.times do
        post onboarding_path, params: {account: {name: "Test Account"}}
      end

      # 6th request should be throttled
      post onboarding_path, params: {account: {name: "Test Account"}}
      expect(response.status).to eq(429)
    end
  end

  describe "Login rate limiting by email" do
    it "allows up to 5 login attempts per email" do
      5.times do
        post user_session_path, params: {user: {email: user.email, password: "wrong"}}
        expect(response.status).not_to eq(429)
      end
    end

    it "throttles after 5 failed login attempts per email" do
      # Make 5 allowed requests
      5.times do
        post user_session_path, params: {user: {email: user.email, password: "wrong"}}
      end

      # 6th request should be throttled
      post user_session_path, params: {user: {email: user.email, password: "wrong"}}
      expect(response.status).to eq(429)
    end
  end

  describe "Login rate limiting by IP" do
    it "allows up to 10 login attempts per IP" do
      10.times do |i|
        post user_session_path, params: {user: {email: "user#{i}@example.com", password: "wrong"}}
        expect(response.status).not_to eq(429)
      end
    end

    it "throttles after 10 attempts per IP" do
      # Make 10 allowed requests with different emails
      10.times do |i|
        post user_session_path, params: {user: {email: "user#{i}@example.com", password: "wrong"}}
      end

      # 11th request should be throttled
      post user_session_path, params: {user: {email: "user11@example.com", password: "wrong"}}
      expect(response.status).to eq(429)
    end
  end

  describe "Account creation rate limiting" do
    before { sign_in user }

    it "allows up to 5 account creations per hour" do
      5.times do |i|
        post accounts_path, params: {account: {name: "Account #{i}"}}
        expect(response.status).not_to eq(429)
      end
    end
  end

  describe "Password reset rate limiting" do
    it "allows up to 3 password reset requests per hour" do
      3.times do
        post user_password_path, params: {user: {email: user.email}}
        expect(response.status).not_to eq(429)
      end
    end

    it "throttles after 3 password reset attempts" do
      # Make 3 allowed requests
      3.times do
        post user_password_path, params: {user: {email: user.email}}
      end

      # 4th request should be throttled
      post user_password_path, params: {user: {email: user.email}}
      expect(response.status).to eq(429)
    end
  end
end
