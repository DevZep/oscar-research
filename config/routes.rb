Rails.application.routes.draw do
  root to: 'dashboard#index'
  get '/dashboard' => 'dashboard#index'

  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions', passwords: 'passwords' }

  resources :clients, only: [:index, :show]
  resources :advanced_search_save_queries

  scope 'admin' do
    resources :users
  end

  namespace :api do
    resources :clients, only: [:index]
  end
end
