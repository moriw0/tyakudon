Rails.application.routes.draw do
  root 'home#index'
  get '/about', to: 'statics#about'
  get '/search', to: 'home#search'
  get '/near_shops', to: 'ramen_shops#near_shops'
  get '/signup', to: 'users#new'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :ramen_shops, only: [:index, :show, :new, :create, :edit, :update] do
    resources :records, only: [:show, :new, :create, :edit, :update], shallow: true do
      member do
        get 'measure'
        patch 'calculate'
        get 'result'
        post 'retire'
      end
      resources :line_statuses, except: [:index, :destroy]
    end
  end
  resources :users do
    get 'favorite_shops', on: :member, as: :favorites_by
    patch 'update_test_mode', on: :member
  end
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :favorites, only: [:create, :destroy]
end
