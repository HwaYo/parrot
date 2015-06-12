Rails.application.routes.draw do

  use_doorkeeper
  mount API => '/'

  root 'home#index'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get "signout", to: "sessions#destroy"

  get 'share/:share_token', to: 'share#show', constraints: {:share_token => /[a-z0-9]{10}/}

  resources :bookmarks

  resources :records do
    member do
      get 'bookmark_json'
      get 'share'
      post 'share', to: 'records#share_new'
      delete 'share', to: 'records#share_stop'
    end
  end

  resources :ping, only: :index

  resources :subscriptions, only: :create
end
