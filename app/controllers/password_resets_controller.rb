class PasswordResetsController < ApplicationController

  skip_before_action :set_organization
  before_action :find_user,             only: [:edit, :update]
  before_action :user_can_be_retrieved, only: [:edit, :update]
  before_action :check_expiration,      only: [:edit, :update]
  
  def new
  end

  def create
    # unless params[:commit] == "Cancel"
      @user = User.find_by(email: params[:password_reset][:email].downcase)
      if @user
        @user.create_reset_digest
        @user.send_password_reset_email
        msg  = "Email sent to #{@user.email} with instructions "
        msg += "on how to reset your password." 
        flash[:info] = msg
        redirect_to root_url
      else
        flash.now[:danger] = "Email address not found."
        render 'new'
      end
    # else
    #   redirect_to user_path(current_user)
    # end
  end

  def edit
    @reset = params[:id]
  end

  def update
    if params[:user][:password].blank?
      flash.now[:danger] = "Password can't be blank."
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to user_path(current_user)
    else
      render 'edit'
    end
  end
  
  private
  
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
  
    def find_user
      @user = User.find_by(email: params[:email])
    end

    def user_can_be_retrieved
      unless @user && @user.activated? && @user.authenticated?(:reset, params[:id])
        redirect_to root_url
      end
    end
  
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
