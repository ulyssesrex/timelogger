class StaticPagesController < ApplicationController
  before_action :logged_in, only: [:help]
  
  def home
  end
  
  def about
  end
  
  def help
  end
end