require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users
  resources :properties do
    resources :comments, only: [:create, :edit, :update, :destroy]
    resources :agreements, only: [:index, :new, :create]
    collection do
      get 'owner_dashboard'
    end
    member do
      get 'contact', to: 'properties#new_contact'
      post 'contact', to: 'properties#send_contact'
      # get 'show_agreement'
      # get 'agreements', to: 'agreements#index', as: :rental_agreements
    end
  end

  # resources :agreements, only: [:new, :create, :show, :edit, :update] do
  #   member do
  #     # Route to delete documents
  #     delete 'document/:id', to: 'agreements#destroy_document', as: :document
  #   end
  # end

  resources :messages, only: [:create, :index]


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
