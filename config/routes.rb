Rails.application.routes.draw do
  root 'home#index'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get "signout", to: "sessions#destroy"

  resources :bookmarks

  resources :records do
    member do
      get 'bookmark_json'
    end
  end
end
