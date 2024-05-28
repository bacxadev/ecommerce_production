Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]
  root to: "home#index"
  get "/user_management", to: "user_management#index"
  get "/new_admin", to: "user_management#new_admin"
  get "/new_domain", to: "user_management#new_domain"
  post "/create_domain", to: "user_management#create_domain"
  post "/create_admin", to: "user_management#create_admin"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
