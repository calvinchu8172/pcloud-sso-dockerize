Rails.application.routes.draw do

  root 'personal#index'
  post '/d/1/:action' => "device"
  
  get 'hint/signup'
  get 'hint/confirm'
  
  post 'ddns/check'
  post 'discoverer/search'

  get 'registrations/success'
  # get '/pairing/index/:id' => "pairing#index", :constraints => {:id => /\d/}
  devise_for :users, :controllers => { :registrations => "registrations", :confirmations => 'confirmations', :omniauth_callbacks => "users/omniauth_callbacks" }

  get 'device/register'
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  resources :upnp

  get 'upnp/check/:id' , to: 'upnp#check'
  get '/:controller(/:action(/:id))(.format)'
  post 'oauth/confirm'
end
