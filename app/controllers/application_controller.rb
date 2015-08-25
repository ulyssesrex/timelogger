class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  protect_from_forgery with: :exception    
  include ApplicationHelper
  include SessionsHelper

  # after_action :check_for_timer_activation
    
  ###-----Before actions-----###

  # # Persists activated timer from time of mouse click
  # # through page refreshes.
  # def check_for_timer_activation
  #   if session[:timelog_start]
  #     render file: "/app/views/timelogs/start_from_button.js"
  #   end
  # end

  # Through 'acts_as_tenant' gem,
  # limits all SQL queries to current_user's organization.
  def set_organization
    current_organization = Organization.find(current_user.organization_id)
    set_current_tenant(current_organization)
  end
  
  # Redirects to user page if user doesn't have admin status.
  def admin
    unless current_user.admin?
      flash[:danger] = "Sorry, you must be an admin to do that."
      redirect_to user_path(current_user)
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
