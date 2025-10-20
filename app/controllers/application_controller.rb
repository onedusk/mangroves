# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError do |_exception|
    redirect_to root_path, alert: "You are not authorized to perform this action."
  end

  helper_method :current_account, :current_workspace

  def current_account
    Current.account
  end

  def current_workspace
    Current.workspace
  end
end
