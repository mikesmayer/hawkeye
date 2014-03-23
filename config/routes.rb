RailsBootstrap::Application.routes.draw do

  namespace :p42 do
    
  end

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

    resources :menu_items do 
      collection do
        post :sync_menu_items
      end
    end

    resources :discounts do 
      collection do
        post :sync_discounts
      end
    end

    resources :tickets do
      collection do
        post :sync_tickets
        post :index
      end
    end

    resources :discount_items
    resources :ticket_items


  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root :to => 'home#index'

  resources :approved_users
  resources :users  
  resources :ftp_connects
  resources :restaurants

end
