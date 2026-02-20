Rails.application.routes.draw do
  # Prototype routes for UI testing
  get "/prototypes", to: "prototypes#index"
  get "/prototypes/command_deck", to: "prototypes#command_deck"
  get "/prototypes/context_aware", to: "prototypes#context_aware"
  get "/prototypes/action_rows", to: "prototypes#action_rows"

  # Temporary root for development (remove before production)
  root "prototypes#command_deck"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
