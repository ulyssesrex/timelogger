class AccountActivationsController < ApplicationController
  skip_before_action :set_organization

  def edit_organization
    @organization = Organization.find_by(name: params[:organization_name])
    @organization_token = params[:organization_token]
    @admin = @organization.try(:users).try(:find_by, email: params[:email])
    @admin_token = params[:id]
    auth_activate_and_login_admin(@admin, @admin_token, @organization, @organization_token)
  end

  def edit_user
    @organization = Organization.find(params[:organization_id])
    if !params[:user_id].blank?
      @user = @organization.try(:users).try(:find, params[:user_id])
    else
      @user = nil
    end
    @user_token = params[:id]
    auth_activate_and_login_user(@user, @user_token)
  end

  private

  def auth_activate_and_login_user(user, token)
    if user && !user.activated && user.authenticated?(:activation, token)
      user.activate
      log_in user
      flash[:success] = "Account activated. Welcome, #{@user.first_name}!"
      redirect_to user and return
    else
      flash[:danger] = "Invalid activation link."
      redirect_to root_path and return
    end
  end

  def auth_activate_and_login_admin(admin, admin_token, org, org_token)
    if admin && !admin.activated && admin.authenticated?(:activation, admin_token) && org.authenticated?(:activation, org_token)
      admin.activate
      log_in admin
      flash[:success] = "Account activated. Welcome, #{@admin.first_name}!"
      redirect_to admin_help_path and return
    else
      flash[:danger] = "Invalid activation link."
      redirect_to root_path and return
    end
  end  
end