Rails.application.routes.draw do

  # Routes for Pcloud portal
  constraints :host => Settings.environments.portal_domain do
    devise_scope :user do
      # setting root path to personal index page, if user signed in
      authenticated :user do
        # root 'personal#index', as: :authenticated_root
        root 'personal#blank', as: :authenticated_root
      end

      # setting root path to sign in page, if user not sign in
      unauthenticated do
        root 'sessions#new', as: :unauthenticated_root
      end
    end

    use_doorkeeper scope: 'oauth' do
      controllers authorizations: 'oauth2/authorizations',
                  tokens: 'oauth2/tokens',
                  applications: 'oauth2/applications',
                  authorized_applications: 'oauth2/authorized_applications'
    end

    get 'hint/signup'
    get 'hint/confirm'
    get 'hint/reset'
    get 'hint/sent'
    get 'hint/agreement'
    get 'hint/confirm_sent'
    get 'help', to: 'help#index'

    devise_for :users, :controllers => {
      :registrations => "registrations",
      :confirmations => 'confirmations',
      :sessions => "sessions",
      :passwords => 'passwords',
      :omniauth_callbacks => "users/omniauth_callbacks"}

    devise_scope :user do
      get   'users/confirmation/edit', to: 'confirmations#edit'
      patch 'users/confirmation',      to: 'confirmations#update'
      get   'oauth/new',               to: 'users/omniauth_callbacks#new'
      post  'oauth/new',               to: 'users/omniauth_callbacks#confirm'
      get   'oauth/login',             to: 'users/omniauth_callbacks#login'
      post  'oauth/login',             to: 'users/omniauth_callbacks#logining'
      resources :edm_users, only: :index, controller: 'users/edm_users' do
        collection do
          get 'download', to: 'users/edm_users#download_csv'
        end
      end
    end

    get 'ddns/:id', to: 'ddns#show'
    get 'ddns/success/:id', to: 'ddns#success'
    get 'ddns/failure/:id', to: 'ddns#failure'
    post 'ddns/check'

    get 'discoverer/index', to: 'discoverer#index'
    get 'discoverer/add'
    get 'discoverer/check/:id', to: 'discoverer#check'
    get 'discoverer/indicate/:id', to: 'discoverer#indicate'
    post 'discoverer/search'

    get 'personal/index'
    get 'personal/profile'
    get 'personal/device_info/:id', to: 'personal#device_info'
    get 'personal/check_status/:id', to: 'personal#check_status'

    unless Rails.env.production?
      mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
    end

    get 'pairing/index/:id', to: 'pairing#index'
    get 'pairing/waiting/:id', to: 'pairing#waiting'
    get 'pairing/check_connection/:id', to: 'pairing#check_connection'
    get 'pairing/cancel/:id', to: 'pairing#cancel'

    resources :package, only: [ :show, :edit, :update ]
    get 'package/check/:id' , to: 'package#check'
    get 'package/cancel/:id', to: 'package#cancel', as: 'cancel_package'

    concern :upnp_mods do
      resources :upnp, only: [ :show, :edit, :update ]
      get 'upnp/cancel/:id', to: 'upnp#cancel', format: 'json'
      get 'upnp/check/:id', to: 'upnp#check', format: 'json'
    end

    scope :path => '/1/', :module => 'mods/v1' do
      concerns :upnp_mods
    end

    scope :path => '/2/', :module => 'mods/v2' do
      concerns :upnp_mods
      get 'upnp/reload/:id', to: 'upnp#reload', format: 'json'
    end

    get 'unpairing/index/:id', to: 'unpairing#index', as: 'unpairing_index'
    get 'unpairing/success/:id', to: 'unpairing#success', as: 'unpairing_success'
    get 'unpairing/destroy/:id', to: 'unpairing#destroy', as: 'unpairing_destroy'

    get 'invitations/accept/:id', to: 'invitations#accept'
    get 'invitations/accept', to: 'invitations#accept'
    get 'invitations/check_connection/:id', to: 'invitations#check_connection'

    resources :products, :path => "fs2g0a2vtz", except: [:destroy]
    get 'diagram', to: 'diagram#index'
  end

  # Routes for Pcloud REST API server
  constraints :host => Settings.environments.api_domain  do

    scope module: 'oauth2' do
      namespace :api do
        namespace :v1 do
          get 'my/info', to: 'my#info', format: 'json'
        end
      end
    end

  end

  # Catch all routes
  root "application#raise_not_found!", via: :all
  get "*path", to: "application#raise_not_found!", via: :all
end
