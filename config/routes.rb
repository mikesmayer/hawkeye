RailsBootstrap::Application.routes.draw do

  namespace :p42 do
    resources :menu_item_groups do
      collection do
        post :sync_menu_item_groups
      end
    end
  end

  namespace :p42 do
    resources :meal_count_rules
  end

  namespace :p42 do
    resources :menu_items
  end

  resources :restaurants

  namespace :p42 do
    resources :ticket_items
  end

  namespace :p42 do
    resources :tickets
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root :to => 'home#index'

  resources :approved_users
  resources :users  
  resources :ftp_connects

end
