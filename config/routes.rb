Rails.application.routes.default_url_options[:host] = 'localhost:3000'
Rails.application.routes.draw do

  resources :users do
    resources :supervisions,  only:   [:create, :destroy]   
    resources :grantholdings, only:   [:new, :create, :destroy]
    resources :timelogs,      except: [:show] do
      post 'end_from_button', to: 'timelogs#end_from_button', on: :collection
      post 'filter_index',    to: 'timelogs#filter_index',    on: :collection
      post 'day_index',       to: 'timelogs#day_index',       on: :collection
    end
  end
  
  resources :sessions,            only: [:new, :create, :destroy]
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :organizations,       only: [:show]

  scope "/admin" do
    get    'admin_help',  to: 'static_pages#admin_help'
    get    'make_admin',  to: 'users#make_admin_index'
    put    'make_admin',  to: 'users#make_admin'
    get    'delete_user', to: 'users#delete_other_user_index'
    delete 'delete_user', to: 'users#delete_other_user'
    resources :keyword_resets, only:   [:new, :create, :edit, :update]
    resources :grants,         except: [:show]
    resources :organizations,  except: [:show, :index]
  end
  
  get    'login',  to: 'sessions#new'
  post   'login',  to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy' 
  get    'home',   to: 'static_pages#home'
  get    'about',  to: 'static_pages#about'
  get    'help',   to: 'static_pages#help'
  get    'signup', to: 'users#new'
  post   'signup', to: 'users#create'
  root   'static_pages#home'
end
