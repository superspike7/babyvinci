Rails.application.routes.draw do
  root "home#show"
  resource :today, only: :show, controller: :home
  resource :timeline, only: :show, controller: :timeline
  resource :more, only: :show, controller: :more
  resource :next_feed_reminder, only: %i[create update destroy]
  resources :baby_invites, only: %i[new create show]
  resources :feeds, only: %i[new create]
  resources :diapers, only: %i[new create]
  resources :care_events, only: %i[edit update destroy]
  get "join/:token", to: "invites#show", as: :invite
  post "join/:token", to: "invite_acceptances#create", as: :invite_acceptance

  get "login", to: "sessions#new", as: :login
  get "signup", to: "users#new", as: :signup

  resources :users, only: %i[new create]
  resource :session
  resources :babies, only: %i[new create]
  resources :passwords, param: :token
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
