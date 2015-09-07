Rails.application.routes.default_url_options[:host] = 'localhost:3000'
# TODO: different host.

Rails.application.routes.draw do
  resources :users do
    collection do
      post 'grants_fulfillments_table'
    end
  end
    resources :timelogs, except: [:index] do
    collection do
      post 'timer_start'
      post 'finish_from_button'
    end
  end
  resources :grants   
  resources :organizations,       except: [:index]
  resources :grantholdings,       except: [:show]
  resources :supervisions,        only:   [:create, :destroy]
  resources :account_activations, only:   [:edit]
  resources :password_resets,     only:   [:new, :create, :edit, :update]
  
  get    'home'          => 'static_pages#home'
  get    'about'         => 'static_pages#about'
  get    'help'          => 'static_pages#help'
  get    'help/admin'    => 'static_pages#admin_help'
  get    'signup'        => 'users#new'
  post   'signup'        => 'users#create'
  get    'make_admin'    => 'users#make_admin_index'
  put    'make_admin'    => 'users#make_admin'
  get    'delete_user'   => 'users#delete_other_user_index'
  delete 'delete_user'   => 'users#delete_other_user'
  get    'timelogs/:id'  => 'timelogs#index'
  get    'login'         => 'sessions#new'
  post   'login'         => 'sessions#create'
  delete 'logout'        => 'sessions#destroy'
  get    'all_coworkers' => 'users#index'
  get    'supervisees'   => 'supervisions#supervisees'
  root   'static_pages#home'
end
