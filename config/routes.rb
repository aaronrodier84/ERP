Rails.application.routes.draw do

  require 'sidekiq/web'
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, :controllers => {:registrations => "registrations"}

  resources :products, :only => [:index, :show, :update] do
    get 'barcode', on: :member
    get 'at-zone/:zone_id', on: :collection, to: 'products#products_at_zone', as: :zone

    put 'save_internal_title', on: :member

    get  'edit_ingredients', on: :member, to: 'ingredients#edit'
    post 'ingredients', on: :member, to: 'ingredients#update'
  end

  resources :batches do
    collection do
      get 'get_chart_data'
      post 'create_with_shipment'
    end
  end

  resources :vendors
  resources :materials
  
  namespace :admin do
    resources :users

    resources :zones, only: [:index, :edit, :update ]

    resources :dashboard, :only => :index
    get 'fetch_products', to: 'dashboard#fetch_products'

    get 'refresh_fba_allocations', to: 'dashboard#refresh_fba_allocations'

    resource :settings, only: [:edit, :update]
  end

  root 'products#index'
end
