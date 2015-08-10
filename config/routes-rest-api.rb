Rails.application.routes.draw do
  # get '*unmatched_route', :to => 'application#raise_not_found!'

  # get "/404", :to => 'application#raise_not_found!'

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

  get "*path", to: "application#raise_not_found!", via: :all
end
