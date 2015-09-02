Rails.application.routes.default_url_options[:host] = 'localhost:3000'
# TODO: different host.

Rails.application.routes.draw do
  resources :users
  resources :grants   
  resources :organizations,       except: [:index]
  resources :grantholdings,       except: [:show]
  resources :supervisions,        only:   [:create, :destroy]
  resources :timelogs,          except: [:index]
  resources :account_activations, only:   [:edit]
  resources :password_resets,     only:   [:new, :create, :edit, :update]
  
  get    'home'           => 'static_pages#home'
  get    'about'          => 'static_pages#about'
  get    'help'           => 'static_pages#help'
  get    'signup'         => 'users#new'
  post   'signup'         => 'users#create'
  get    '/users/make_admin/' => 'users#make_admin_index'
  put    '/users/make_admin/:id' => 'users#make_admin'
  get    '/users/delete_other_user' => 'users#delete_other_user_index'
  delete '/users/delete_other_user/:id' => 'users#delete_other_user'
  post   '/users/grants_fulfillments_table' => 'users#grants_fulfillments_table'
  post   '/timelogs/timer_start' => 'timelogs#timer_start'
  post   '/timelogs/finish_from_button' => 'timelogs#finish_from_button'
  get    'login'          => 'sessions#new'
  post   'login'          => 'sessions#create'
  delete 'logout'         => 'sessions#destroy'
  get    'all_coworkers'  => 'supervisions#all_coworkers'
  get    'supervisees'    => 'supervisions#supervisees'
  root   'static_pages#home'
end
