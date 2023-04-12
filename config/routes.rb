Rails.application.routes.draw do
  root 'ramen_shops#index'
  resources :ramen_shops, only: [:index, :show] do
    resources :records, only: :create
  end
end
