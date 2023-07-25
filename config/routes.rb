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
      patch 'calculate', on: :member
      get 'result', on: :member
      resources :line_statuses
    end
  end
  resources :users do
      get 'favorite_shops', on: :member, as: :favorites_by
  end
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :favorites, only: [:create, :destroy]
end
