Rails.application.routes.draw do
  root 'home#index'
  get '/about', to: 'statics#about'
  get '/search', to: 'home#search'
  get '/near_shops', to: 'ramen_shops#near_shops'
  resources :ramen_shops, only: [:index, :show] do
    resources :records, only: :create
  end
end
