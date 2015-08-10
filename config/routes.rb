Rails.application.routes.draw do
  # get '*unmatched_route', :to => 'application#raise_not_found!'

  # get "/404", :to => 'application#raise_not_found!'

  constraints :host => Settings.environments.portal_domain do
    devise_scope :user do
      # setting root path to personal index page, if user signed in
      authenticated :user do
        root 'personal#index', as: :authenticated_root
      end

      # setting root path to sign in page, if user not sign in
      unauthenticated do
        root 'devise/sessions#new', as: :unauthenticated_root
      end
    end

    get 'hint/signup'
    get 'hint/confirm'
    get 'hint/reset'
    get 'hint/sent'
    get 'hint/agreement'
    get 'hint/confirm_sent'

    resources :ddns
    post 'ddns/check'
    post 'discoverer/search'

    get 'registrations/success'

    devise_for :users, :controllers => {
      :registrations => "registrations",
      :confirmations => 'confirmations',
      :sessions => "sessions",
      :passwords => 'passwords',
      :omniauth_callbacks => "users/omniauth_callbacks"}

    devise_scope :user do
      get 'users/confirmation/edit', to: "confirmations#edit"
      patch 'users/confirmation', to: "confirmations#update"
    end

    get 'device/register'

    unless Rails.env.production?
      mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
    end

    resources :package

    scope :path => '/1/', :module => 'mods/v1' do
      resources :upnp
      get 'upnp/check/:id', to: 'upnp#check', format: 'json'
      get 'upnp/cancel/:id', to: 'upnp#cancel', format: 'json'
    end

    scope :path => '/2/', :module => 'mods/v2' do
      resources :upnp
      get 'upnp/check/:id', to: 'upnp#check', format: 'json'
      get 'upnp/cancel/:id', to: 'upnp#cancel', format: 'json'
    end

    get 'package/check/:id' , to: 'package#check'
    get '/:controller(/:action(/:id))(.format)'
    post 'oauth/confirm'
  end

  constraints :host => Settings.environments.api_domain  do

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
      delete 'permission', to: 'permissions#destroy', format:'json'
      get 'device_list', to: 'personal#device_list', format: 'json'
    end

    root "application#raise_not_found!", via: :all
  end

  get "*path", to: "application#raise_not_found!", via: :all
end
