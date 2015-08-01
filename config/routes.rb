Rails.application.routes.default_url_options[:host] = 'localhost:3000'
# TODO: different host.

Rails.application.routes.draw do
  resources :users
  resources :grants   
  resources :organizations,       except: [:index]
  resources :grantholdings,       except: [:show]
  resources :supervisions,        only:   [:create, :destroy]
  resources :timesheets,          except: [:index]
  resources :account_activations, only:   [:edit]
  resources :password_resets,     only:   [:new, :create, :edit, :update]
  
  get  'home'           => 'static_pages#home'
  get  'about'          => 'static_pages#about'
  get  'help'           => 'static_pages#help'
  get  'signup'         => 'users#new'
  post 'signup'         => 'users#create'
  get  'login'          => 'sessions#new'
  post 'login'          => 'sessions#create'
  post 'logout'         => 'sessions#destroy'
  get  'all_coworkers'  => 'supervisions#all_coworkers'
  get  'supervisees'    => 'supervisions#supervisees'
  get  'delete_user'    => 'users#destroy_other'
  get  'make_admin'     => 'users#make_admin'
  root 'static_pages#home'
end
