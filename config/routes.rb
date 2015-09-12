Rails.application.routes.default_url_options[:host] = 'localhost:3000'
# TODO: different host.

Rails.application.routes.draw do

  get 'keyword_resets/new'

  get 'keyword_resets/create'

  get 'keyword_resets/edit'

  get 'keyword_resets/update'

  resources :users do
    post 'grants_fulfillments_table', 
      to: 'users#grants_fulfillments_table', 
      on: :member
    resources :supervisions,  only: [:create, :destroy]
    resources :grantholdings
    resources :timelogs do
      post 'timer_start', to: 'timelogs#new', on: :member
      post 'finish_from_button', to: 'timelogs#finish_from_button', on: :collection
    end
  end
  
  resources :sessions, only: [:new, :create, :destroy]
  get 'get_current_user_id', to: 'sessions#get_current_user_id'

  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :keyword_resets,      only: [:new, :create, :edit, :update]
  resources :organizations,       only: [:show]

  scope "/admin" do
    get    'admin_help',  to: 'static_pages#admin_help'
    get    'make_admin',  to: 'users#make_admin_index'
    put    'make_admin',  to: 'users#make_admin'
    get    'delete_user', to: 'users#delete_other_user_index'
    delete 'delete_user', to: 'users#delete_other_user'
    get    'reset_keyword/:id', 
      to:  'organizations#reset_keyword_form', 
      as:  'reset_keyword_form'
    patch  'reset_keyword/:id',
      to:  'organizations#reset_keyword',
      as:  'reset_keyword'
    resources :grants, except: [:show]
    resources :organizations, except: [:show, :index]
  end
  
  get    'login',  to: 'sessions#new'
  post   'login',  to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy' 
  get    'home',   to: 'static_pages#home'
  get    'about',  to: 'static_pages#about'
  get    'help',   to: 'static_pages#help'
  get    'signup', to: 'users#new'
  post   'signup', to: 'users#create'
  get    'supervisees', to: 'supervisions#supervisees'

  root   'static_pages#home'
end
