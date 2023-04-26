Rails.application.routes.draw do
  root 'ramen_shops#index'
  get '/about', to: 'statics#about'
  get '/search', to: 'home#search'
  resources :ramen_shops, only: [:index, :show] do
    resources :records, only: :create
  end
end
