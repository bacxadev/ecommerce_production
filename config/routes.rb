Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]
  root to: "home#index"
  get "/user_management", to: "user_management#index"
  get "/new_admin", to: "user_management#new_admin"
  get "/new_domain", to: "user_management#new_domain"
  post "/create_domain", to: "user_management#create_domain"
  post "/load_products", to: "user_management#load_products"
  post "/create_admin", to: "user_management#create_admin"
  namespace :api do
    namespace :v1 do
      resources :checkout do
        collection do
          post :import_checkout_success
        end
      end
    end
  end

  mount ActionCable.server => '/cable'
end
