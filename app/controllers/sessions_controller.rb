class SessionsController < ApplicationController  
  before_action :find_user,       only: [:create]
  before_action :valid_user,      only: [:create]
  before_action :activated_user,  only: [:create]
  
  def new
  end
  
  def create
    log_in @user
    params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
    redirect_back_or user_path(@user)
  end
  
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
  
  private
    
    def find_user
      @user = User.find_by(email: params[:session][:email].downcase)
    end
  
    def valid_user
      unless @user && @user.authenticate(params[:session][:password])
        flash.now[:danger] = "Invalid email and/or password."
        render 'new'
      end
    end
    
    def activated_user
      unless @user.activated?
        message =  "Your account is not activated yet."
        message += " If you've already registered,"
        message += " check your email for a Timelogger activation email."
        # TODO: Perhaps add a link here to generate another activation email instead.
        # This would most likely be a POST :create, :controller => :users action.
        flash[:warning] = message
        redirect_to root_url
      end
    end
end