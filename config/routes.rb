RailsBootstrap::Application.routes.draw do

  namespace :tacos do
    resources :meal_count_rules
  end

  namespace :tacos do
    resources :menu_items
  end

  namespace :tacos do
    resources :ticket_items
  end

  namespace :tacos do
    resources :menu_item_groups
  end

  resources :tip_jar_donations

#post 'p42/ticket_items/files/save_to_local', :controller => 'p42/ticket_items', :action => 'save_file_to_local'
  post 'p42/ticket_items/parse_csv', :controller => 'p42/ticket_items', :action => 'parse_csv'
  get 'p42/ticket_items/calculate_meals', :controller => 'p42/ticket_items', :action => 'calculate_meals'
  match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]
  get 'meals/detail_counts', :controller => 'meals', :action => 'counts'
  get 'meals/month_counts', :controller => 'meals', :action => 'month_counts'
  get 'meals/year_counts', :controller => 'meals', :action => 'year_counts'
  get 'meals/count_totals', :controller => 'meals', :action => 'count_totals'
  get 'meals/product_mix', :controller => 'meals', :action => 'product_mix'
  get 'meals/category_product_mix', :controller => 'meals', :action => 'category_product_mix'
  

  get 'item_sales/items', :controller => 'item_sales', :action => 'items'
  get 'items', :controller => 'item_sales', :action => 'items'
  get 'item_sales/aggregate_items', :controller => 'item_sales', :action => 'aggregate_items'
  get 'aggregate_items', :controller => 'item_sales', :action => 'aggregate_items'
  get 'item_sales/sales_totals', :controller => 'item_sales', :action => 'sales_totals'
  get 'sales_totals', :controller => 'item_sales', :action => 'sales_totals'

  get 'google_drive_sync', :controller => 'google_drive_sync', :action => 'index'
  get 'google_drive_sync/file_list', :controller => 'google_drive_sync', :action => 'file_list'
  get 'google_drive_sync/folder', :controller => 'google_drive_sync', :action => 'folder'
  get 'google_drive_sync/get_file', :controller => 'google_drive_sync', :action => 'get_file'
  get 'google_drive_sync/search', :controller => 'google_drive_sync', :action => 'search'
  resources :item_sales
    
  resources :meals, :only => [] do
    collection do
      get :index
    end
  end

  namespace :p42 do
    resources :ticket_items do
      collection do
        get :files
        get :file_list
      end
    end
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
        delete :destroy_multiple
      end
    end

    resources :discount_items
    resources :ticket_items


  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root :to => 'item_sales#index'

  resources :approved_users
  resources :users  
  resources :ftp_connects
  resources :restaurants



end
