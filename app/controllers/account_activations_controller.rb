class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Account activated. Welcome, #{user.first_name}!"
      redirect_to help_url and return if user.admin?
    else
      flash[:danger] = "Invalid activation link."
    end
    redirect_to root_url  
  end
end