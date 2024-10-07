require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  # mount ActionCable.server => '/cable'

  devise_for :users
  resources :properties do
    resources :comments, only: [:create, :edit, :update, :destroy]
    resources :agreements, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
      # patch 'complete', on: :member
      member do
        patch 'sign_owner'  # Owner signs the agreement
        patch 'send_to_tenant'  # Sends to tenant after owner signature
        patch 'complete'
        get 'sign_by_tenant'  # Route for tenant to access and sign the agreement
        patch 'update_by_tenant'  # Tenant signs the agreement
      end
    end
    resources :messages, only: [:index, :create]
    collection do
      get 'owner_dashboard'
    end
    member do
      get 'contact', to: 'properties#new_contact'
      post 'contact', to: 'properties#send_contact'
    end
  end

  patch '/update_language', to: 'users#update_language', as: 'update_language'

  # routes for blueprint supported APIs
  namespace :api do
    namespace :v1 do
      resources :properties, only: [:index, :show, :create, :update, :destroy] do
        # resources :comments, only: [:create, :edit, :update, :destroy]
        collection do
          get 'owner_dashboard', to: 'properties#owner_dashboard'
        end
        member do
          get 'contact', to: 'properties#new_contact'
          post 'contact', to: 'properties#send_contact'
        end
      end
    end
  end



  # resources :users
  # get 'home/index'
  root 'home#index'

  get 'home/about'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

end
