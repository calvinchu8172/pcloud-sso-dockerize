Rails.application.routes.draw do
  # get '*unmatched_route', :to => 'application#raise_not_found!'

  # get "/404", :to => 'application#raise_not_found!'

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
    get 'upnp/reload/:id', to: 'upnp#reload', format: 'json'
    get 'upnp/cancel/:id', to: 'upnp#cancel', format: 'json'
  end

  get 'unpairing/index/:id', to: 'unpairing#index', as: 'unpairing_index'
  get 'unpairing/success/:id', to: 'unpairing#success', as: 'unpairing_success'
  resources :unpairing, only: [:destroy]

  get 'package/check/:id' , to: 'package#check'
  get '/:controller(/:action(/:id))(.format)'
  post 'oauth/confirm'

  get "*path", to: "application#raise_not_found!", via: :all
end
