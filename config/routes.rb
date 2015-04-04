Rails.application.routes.draw do
  root 'dashboard#index'

  resources :records, only: [:new, :create]
end
