class AccountActivationsController < ApplicationController
  skip_before_action :set_organization

  def edit
    @organization = Organization.find_by(name: params[:organization_name])
    @organization_token = params[:organization_token]
    @user = @organization.try(:users).try(:find_by, email: params[:email])
    @user_token = params[:id]

    #binding.pry

    if valid_link?(@user, @organization, @organization_token, @user_token)
      @user.activate
      log_in @user
      flash[:success] = "Account activated. Welcome, #{@user.first_name}!"
      if @user.admin?
        redirect_to admin_help_path and return
      end
    else
      flash[:danger] = "Invalid activation link."
      redirect_to root_path and return
    end
    redirect_to @user
  end

  private

  def valid_link?(user, organization, org_token, user_token)
    user && 
    !user.activated && 
    organization.authenticated?(:activation, org_token) && 
    user.authenticated?(:activation, user_token)
  end
end