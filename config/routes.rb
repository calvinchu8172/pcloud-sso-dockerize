Rails.application.routes.draw do

  # use_doorkeeper scope: 'oauth' do
  #   controllers authorizations: 'oauth2/authorizations',
  #               tokens: 'oauth2/tokens',
  #               applications: 'oauth2/applications',
  #               authorized_applications: 'oauth2/authorized_applications'
  # end

  # scope module: 'oauth2' do
  #   namespace :api do
  #     namespace :v1 do
  #       get 'my/info', to: 'my#info', format: 'json'
  #     end
  #   end
  # end

  # Routes for Pcloud portal
  constraints :host => Settings.environments.portal_domain do
    devise_scope :user do
      # setting root path to personal index page, if user signed in
      authenticated :user do
        root 'personal#index', as: :authenticated_root
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
    # get 'help', to: 'help#index'
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

    resources :package, only: [:show, :edit, :update]
    get 'package/check/:id' , to: 'package#check'
    get 'package/cancel/:id', to: 'package#cancel', as: 'cancel_package'

    concern :upnp_mods do
      resources :upnp, only: [:show, :edit, :update]
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

    resources :products, :path => "fs2g0a2vtz"
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

    # post '/d/1/:action' => "device"
    # post '/d/2/:action' => "device"

    scope :path => '/d/1/', :module => "api/devices/v1" do
      post 'register', to: 'register#create', format: 'json'
    end

    scope :path => '/d/2/', :module => "api/devices/v2" do
      post 'register', to: 'register#create', format: 'json'
    end

    scope :path => '/d/3/', :module => "api/devices/v3" do
      post 'register', to: 'register#create', format: 'json'
      post 'register/lite', to: 'lite#create', format: 'json'
    end

    scope :path => '/user/1/', :module => "api/user", :as => "last_user_api" do
      # match ':controller(/:action(/:id(.:format)))', :via => :all
      resource :token, format: 'json'
      resource :register, format: 'json'
      # put 'email' => 'emails#update', format: 'json'
      resource :email, format: 'json'
      resource :confirmation, format: 'json'
      resource :password, format: 'json'
      resource :xmpp_account, format: 'json'
      get 'checkin/:oauth_provider', to: 'oauth#mobile_checkin', format: 'json'
      post 'register/:oauth_provider', to: 'oauth#mobile_register', format: 'json'
    end

    scope :path => '/resource/1/', :module => "api/resource" do
      post 'invitation', to: 'invitations#create', format: 'json'
      get 'invitation', to: 'invitations#show', format: 'json'
      get 'permission', to: 'permissions#show', format:'json'
      post 'permission', to: 'permissions#create', format:'json'
      delete 'permission', to: 'permissions#destroy', format:'json'
      get 'device_list', to: 'personal#device_list', format: 'json'

      get "vendor_devices", to: "vendor_devices#index", format: 'json'
      post "vendor_devices/crawl", to: "vendor_devices#crawl", format: 'json'
    end

    scope :path => '/healthy/1/', :module => "api/healthy" do
      get 'status', to: 'status#show', format: 'json'
    end

    scope :path => '/device/1/', :module => "api/devices" do
      get 'online_status', to: 'online_status#show', format: 'json'
      put 'online_status', to: 'online_status#update', format: 'json'
    end

  end

  # Catch all routes
  root "application#raise_not_found!", via: :all
  get "*path", to: "application#raise_not_found!", via: :all
end
