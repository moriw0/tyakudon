Rails.application.routes.draw do
  root 'home#index'
  get '/about', to: 'statics#about'
  get '/search', to: 'home#search'
  get '/near_shops', to: 'ramen_shops#near_shops'

  resources :ramen_shops, only: [:index, :show] do
    resources :records, only: [:show, :new, :create, :edit, :update] do
      get 'measure', on: :member

      resources :line_statuses, only: [:index, :new, :create] do
      end
    end
  end
end
