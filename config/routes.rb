Rails.application.routes.draw do

  

  # resources :devices
  root 'discoverer#index'
  post '/d/1/:action' => "device"
  
  get 'hint/signup'
  get 'hint/confirm'
  # get 'pairing/index'
  post 'ddns/check'
  post 'discoverer/search'

  # get 'pairing/add'
    

  # get ':controller(/:action(/:id))'

  # get 'pairing/index'
  # get 'pairing/find'
  # get 'pairing/add'
  # get 'pairing/unpairing'
  # get 'pairing/success'
  # get 'pairing/check'

  get 'registrations/success'
  # get '/pairing/index/:id' => "pairing#index", :constraints => {:id => /\d/}
  devise_for :users, :controllers => { :registrations => "registrations", :confirmations => 'confirmations' }

  get 'device/register'
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  get '/:controller(/:action(/:id))(.format)'


  

  

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
