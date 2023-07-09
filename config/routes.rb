Rails.application.routes.draw do
  root 'home#index'
  get '/about', to: 'statics#about'
  get '/search', to: 'home#search'
  get '/near_shops', to: 'ramen_shops#near_shops'
  get '/signup', to: 'users#new'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :ramen_shops, only: [:index, :show] do
    resources :records, only: [:show, :new, :create, :edit, :update], shallow: true do
      get 'measure', on: :member
      resources :line_statuses
    end
  end
  resources :users
  resources :account_activations, only: [:edit]
end
