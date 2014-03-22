RailsBootstrap::Application.routes.draw do

  namespace :p42 do
    resources :menu_item_groups do
      collection do
        post :sync_menu_item_groups
      end
    end

    resources :revenue_groups do
      collection do
        post :sync_revenue_groups
      end
    end

    resources :meal_count_rules

    resources :menu_items

    resources :ticket_items

    resources :tickets
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root :to => 'home#index'

  resources :approved_users
  resources :users  
  resources :ftp_connects
  resources :restaurants

end
