Rails.application.routes.draw do
  root to: 'dashboard#index'
  get '/dashboard' => 'dashboard#index'

  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions', passwords: 'passwords' }

  get '/robots.txt' => 'dashboard#robots'

  %w(404 500).each do |code|
    match "/#{code}", to: 'errors#show', code: code, via: :all
  end

  resources :clients, only: [:index, :show]
  resources :advanced_search_save_queries

  scope 'admin' do
    resources :users
  end
end
