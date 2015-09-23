class AccountActivationsController < ApplicationController
# possible bug here with acts_as_tenant -- 
# can i set a tenant scope on this action, 
# even though there might be no current user?

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Account activated. Welcome, #{user.first_name}!"
      redirect_to admin_help_path and return if user.admin?
    else
      flash[:danger] = "Invalid activation link."
      redirect_to root_path and return
    end
    redirect_to user_path(user)
  end
end