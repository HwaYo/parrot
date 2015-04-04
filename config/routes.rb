Rails.application.routes.draw do
  # root 'dashboard#index'
  
  root 'home#index'

  get 'dashboard', to: 'dashboard#index'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get "signout", to: "sessions#destroy"


  resources :records, only: [:new, :create, :show]
end
