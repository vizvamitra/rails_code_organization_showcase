Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  resources :home, only: %i[index]
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  namespace :api do
    resource :authentication, only: %i[create]

    namespace :moderation do
      resources :assets, only: %i[index] do
        scope module: :assets do
          resource :activation, only: %i[create destroy]
        end
      end
    end

    scope "/acme", module: :acme_integration do
      resources :identities, only: %i[create]
      resources :pages, only: %i[index]
    end
  end
end
