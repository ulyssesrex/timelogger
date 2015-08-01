class StaticPagesController < ApplicationController
  before_action :logged_in, only: [:help]
  
  def home
    redirect_to user_path(current_user) if logged_in?
  end
  
  def about
  end
  
  def help
  end
end