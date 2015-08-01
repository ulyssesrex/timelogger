class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  protect_from_forgery with: :exception    
  include ApplicationHelper
  include SessionsHelper
    
  ###-----Before actions-----###
  
  # Through 'acts_as_tenant' gem,
  # limits all SQL queries to current_user's organization.
  def set_organization
    current_organization = Organization.find(current_user.organization_id)
    set_current_tenant(current_organization)
  end
  
  # Redirects to root if user doesn't have admin status.
  def admin
    unless current_user.admin?
      flash[:danger] = "Sorry, you must be an admin to do that."
      redirect_to root_url
    end
  end
  
  # Redirects to login page if user isn't logged in.
  def logged_in
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_path
    end
  end
end
