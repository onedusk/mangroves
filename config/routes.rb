# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {registrations: "users/registrations"}

  get "onboarding/new", to: "onboarding#new", as: :onboarding
  post "onboarding/create", to: "onboarding#create"

  resources :accounts do
    member do
      post :switch
    end

    resources :workspaces do
      member do
        post :switch
      end
    end
  end

  root "home#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/components/alert_dialog", to: "components#alert_dialog"
  get "/components/dialog", to: "components#dialog"
  get "/components/drawer", to: "components#drawer"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
