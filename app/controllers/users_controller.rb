class UsersController < ApplicationController
  require 'date'
  
  before_action :logged_in,        
    except: [:new, :create]
  skip_before_action :set_organization, 
    only: [:new, :create]
  before_action :find_user_by_id,  
    only: [:edit, :update, :destroy]
  before_action :is_current_user_or_admin, 
    only: [:edit, :update, :destroy]
  before_action :admin,            
    only: [:delete_other_user_index, :delete_other_user, 
           :make_admin_index, :make_admin]
  
  def new
    @user = User.new
    @organizations = Organization.all || [] # not scoped to tenant
  end
  
  def create
    @user = User.new(user_params)
    @organizations = Organization.all || []
    organization = Organization.find_by(id: params[:user][:organization_id])
    if organization && 
      organization.authenticated?(:password, params[:user][:organization_password])
      @user.organization_id = organization.id
    else
      render 'new' and return
      # TODO: does 'authenticated?' failure produce errors on object?
    end
    if @user.save
      UserMailer.account_activation(@user, organization).deliver_now
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url and return
    else
      render 'new'
    end
  end
  
  def show
    @user = current_user    
  end
    
  def edit
  end
  
  def update
    if @user.update(user_params)
      flash[:success] = "Profile updated."
      redirect_to user_path(current_user) and return
    else
      render 'edit' and return
    end
  end
  
  def index
    @users = User.where(activated: true).where.not(id: current_user.id)
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
    @users = User.where(activated: true).where.not(id: current_user.id)
  end

  def make_admin
    @to_admins  = User.where("id IN (?)", params[:user_ids])
    @to_regular = User.where.not("id IN (?)", params[:user_ids])
    @to_admins.update_all admin: true
    demoted = 0
    @to_regular.each do |reg_user|
      next unless reg_user.admin?
      reg_user.update admin: true
      demoted += 1
    end
    message  = "Admin status granted to #{help.pluralize(@to_admins.count, 'user')}. "
    message += "Admin status removed from #{help.pluralize(demoted, 'user')}."
    flash[:success] = message
    redirect_to users_path
  end

  def add_grantholding_field
    @user = User.find(params[:user_id])
    Grantholding.new(
      user_id: params[:user_id], 
      grant_id: params[:grant_id]
    )
    respond_to do |format|
      format.js
    end
  end
  
  private
    
    def user_params
      params
        .require(:user)
        .permit(
          :first_name, 
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
      @user = User.find(params[:id])
    end

    def find_user_by_email
      @user = User.find_by(email: params[:session][:email]) || current_user
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
