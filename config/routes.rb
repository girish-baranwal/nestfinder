require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users
  resources :properties do
    resources :comments, only: [:create, :edit, :update, :destroy]
    resources :agreements, only: [:index, :new, :create, :show, :edit, :update]
    resources :messages, only: [:index, :create]
    collection do
      get 'owner_dashboard'
    end
    member do
      get 'contact', to: 'properties#new_contact'
      post 'contact', to: 'properties#send_contact'
    end
  end


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
