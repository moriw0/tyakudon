Rails.application.routes.draw do
  root 'ramen_shops#index'
  resources :ramen_shops, only: [:index, :show]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
