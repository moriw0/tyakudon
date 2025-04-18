Rails.application.routes.draw do
  root 'application#route_based_on_authentication'
  get '/lp', to: 'landing_page#index'
  get '/terms', to: 'statics#terms'
  get '/privacy_policy', to: 'statics#privacy_policy'
  get '/ranking', to: 'ranking_records#index'
  get '/new_records', to: 'home#new_records'
  get '/search', to: 'home#search'
  get '/near_shops', to: 'ramen_shops#near_shops'
  get '/signup', to: 'users#new'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get 'auth/:provider/callback', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :ramen_shops, only: [:index, :show, :new, :create, :edit, :update] do
    member do
      get :prepare_favorite
    end
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
  resources :omniauth_users, only: %i[new create]
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :favorites, only: [:create, :destroy]
  resources :favorite_records, only: [:index] do
    get 'filter', on: :collection
  end
  resources :likes, only: [:create, :destroy] do
    member do
      get :prepare
    end
  end
  resources :cheer_messages, only: %i[create]
  resources :shop_register_requests, only: [:new, :create, :edit] do
    get 'complete', on: :member
  end
  resources :faqs
end
