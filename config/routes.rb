Rails.application.routes.draw do

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

  post '/d/1/:action' => "device"
  
  get 'hint/signup'
  get 'hint/confirm'
  get 'hint/reset'
  get 'hint/sent'
  
  post 'ddns/check'
  post 'discoverer/search'

  get 'registrations/success'
  
  devise_for :users, :controllers => { :registrations => "registrations", :confirmations => 'confirmations', :passwords => 'passwords',:omniauth_callbacks => "users/omniauth_callbacks"}

  get 'device/register'
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  resources :upnp

  get 'upnp/check/:id' , to: 'upnp#check'
  get '/:controller(/:action(/:id))(.format)'
  post 'oauth/confirm'
end
