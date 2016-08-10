Rails.application.routes.draw do

  # Routes for Pcloud portal
  constraints :host => Settings.environments.portal_domain do
    devise_scope :user do
      # setting root path to personal index page, if user signed in
      authenticated :user do
        # root 'personal#index', as: :authenticated_root
        root 'welcome#index', as: :authenticated_root
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

    get 'personal/profile'

    unless Rails.env.production?
      mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
    end

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
