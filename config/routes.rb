RailsBootstrap::Application.routes.draw do

  namespace :p42 do
    resources :tickets
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root :to => 'home#index'

  resources :approved_users
  resources :users  
  resources :ftp_connects

end
