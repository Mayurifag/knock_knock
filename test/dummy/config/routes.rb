Rails.application.routes.draw do
  post :admin_token, to: "admin_token#create"
  post :vendor_token, to: "vendor_token#create"

  resource :current_user

  resources :admin_protected
  resources :composite_name_entity_protected
  resources :custom_unauthorized_entity
  resources :guest_protected
  resources :protected_resources
  resources :vendor_protected

  namespace :v1 do
    resources :test_namespaced
  end
end
