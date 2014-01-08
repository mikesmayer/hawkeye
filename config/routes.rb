RailsBootstrap::Application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root :to => 'home#index'

  resources :p42_tickets
  resources :approved_users
  resources :users  
  resources :ftp_connects

end
