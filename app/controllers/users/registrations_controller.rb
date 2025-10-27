# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]

    protected

    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    end

    def after_sign_up_path_for(_resource)
      onboarding_path
    end

    def after_inactive_sign_up_path_for(_resource)
      onboarding_path
    end
  end
end
