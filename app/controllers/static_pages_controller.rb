class StaticPagesController < ApplicationController  
  
  before_action :logged_in, only: [:help, :admin_help]
  before_action :set_organization, except: [:home]
  
  def home
    redirect_to user_path(current_user) if logged_in?
  end
  
  def about
  end
  
  def help
  end

  def admin_help
  end
end