class UsersController < ApplicationController
  require 'date'
  
  before_action :logged_in,        
    except: [:new, :create]
  before_action :set_organization, 
    except: [:new, :create]
  before_action :find_user_by_id,  
    only: [:show, :edit, :update, :destroy, :delete_other_user, :make_admin]
  before_action :is_supervisor_or_current_user_or_admin, 
    only: [:show]
  before_action :is_current_user_or_admin, 
    only: [:edit, :update, :destroy]
  before_action :admin,            
    only: [:delete_other_user_index, :delete_other_user, 
           :make_admin_index, :make_admin]
  
  def new
    @user = User.new
  end
  
  def create
    if params[:commit] == "Cancel"
      redirect_to root_url and return
    else 
      @user = User.new(user_params)
      organization = Organization.find_by(id: params[:user][:organization_id])
      if organization && 
        organization.authenticated?(:password, params[:user][:organization_password])
        @user.organization_id = organization.id
      else
        render 'new' and return
        # TODO: does 'authenticated?' failure produce errors on object?
      end
      if @user.save
        UserMailer.account_activation(@user).deliver_now
        flash[:info] = "Please check your email to activate your account."
        redirect_to root_url and return
      else
        render 'new'
      end
    end
  end
  
  def show
    @grantholdings = @user.grantholdings
    redirect_to users_path unless @user.activated?
  end
  
  def grants_fulfillments_table
    @user = User.find(session[:user_id])
    @grantholdings = @user.grantholdings
    @since_date = User.convert_to_datetime(params[:since_date], time=false)
    respond_to do |format| 
      format.js
    end
  end
    
  def edit
  end
  
  def update
    # If Cancel
    if params[:commit] == "Cancel"
      redirect_to user_path(current_user) and return

    # If Submit -->
    else
      if @user.update(user_params)
        flash[:success] = "Profile updated."
        redirect_to user_path(current_user) and return
      else
        render 'edit' and return
      end
    end
  end
  
  def index
    @users = User.where(activated: true)
  end
  
  def destroy
    @user.destroy
    if current_user?(@user)
      msg  = "Your Timelogger account"
      msg += " has been deleted."
      flash[:success] = msg
      redirect_to root_url and return   
    end
  end

  def delete_other_user_index
    @users = User.where.not(id: current_user.id)
  end

  def delete_other_user
    @selected_users = User.where("id IN (?)", params[:user_ids])
    if @selected_users.none?
      flash[:danger] = "No users selected."
      redirect_to delete_user_path and return
    elsif @selected_users.each { |user| user.destroy }
      flash[:success] = "User successfully deleted."
      redirect_to users_path and return
    end
  end

  def make_admin_index
    @non_admins = User.where(activated: true, admin: false)
  end

  def make_admin
    @selected_users = User.where("id IN (?)", params[:user_ids])
    @selected_users.update_all admin: true
    flash[:success] = "Admin status granted."
    redirect_to users_path
  end
  
  private
    
    def user_params
      params
        .require(:user)
        .permit(:first_name, 
                :last_name,
                :position,
                :email, 
                :password, 
                :password_confirmation,
                :organization_id,
                :organization_password,
                grantholdings_attributes: [
                  :id, 
                  :_destroy, 
                  :required_hours
                ]
         )
    end
    
    def find_user_by_id
      @user = User.find_by(id: params[:id])
    end

    # Before filters with 'or' conditions:
    # If current user meets conditions, proceed normally.
    # Else, redirect to root.
  	
    def is_supervisor_or_current_user_or_admin
      unless
        current_user.supervisees.include?(@user) ||
        current_user?(@user) ||
        current_user.admin? 
        #...
        flash_error_msg
        redirect_to users_path
      end
    end
    
    def is_current_user_or_admin
      unless 
        current_user?(@user) ||
        current_user.admin? 
        #...
        flash_error_msg
        redirect_to user_path(current_user)
      end
    end
    
    def flash_error_msg
      flash[:danger] = "Cannot perform that action."
    end    
end
