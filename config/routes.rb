require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users
  resources :properties do
    resources :comments, only: [:create, :edit, :update, :destroy]
    collection do
      get 'owner_dashboard'
    end
    member do
      get 'contact', to: 'properties#new_contact'
      post 'contact', to: 'properties#send_contact'
    end
  end
  # resources :users
  # get 'home/index'
  root 'home#index'

  get 'home/about'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

end
