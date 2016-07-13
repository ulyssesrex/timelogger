class KeywordResetsController < ApplicationController

  skip_before_action :set_organization, only: [:new, :create]
  #before_action :set_organization,   except: [:new,  :create]

  def new
  end

  def create
  	@admin = User.find_by(email: params[:keyword_reset][:email].downcase)
  	@organization = @admin.organization if @admin
  	if @admin && @organization
  		@organization.create_reset_digest
  		@admin.send_keyword_reset_email(@organization)
  		msg  = "Email sent to #{@admin.email} with instructions on how "
      msg += "to reset #{@organization.name}'s keyword."
      flash[:info] = msg
      redirect_to root_url and return
    else
    	flash.now[:danger] = "Email address not found."
    	render 'new'
    end
  end

  def edit
    @admin = User.find_by(email: params[:email])
    @organization = @admin.organization if @admin
    unless @organization && @organization.authenticated?(:reset, params[:id])
      redirect_to root_url
    end
    if @organization && @organization.keyword_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to new_keyword_reset_url
    end
  	@reset = params[:id]
  end

  def update
    @admin = User.find_by(email: params[:email])
    @organization = @admin.organization if @admin
    unless @organization && @organization.authenticated?(:reset, params[:id])
      redirect_to root_url
    end
    if @organization.keyword_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to new_keyword_reset_url
    end  
    if params[:organization][:password].blank?
      flash.now[:danger] = "Keyword can't be blank."
      render 'edit' and return
    elsif @organization.update_attributes(keyword_params)
      log_in @admin
      flash[:success] = "Keyword has been reset for #{@organization.name}."
      redirect_to user_path(current_user) and return
    else
      render 'edit'
    end
  end

  private

  	def keyword_params
  		params.require(:organization).permit(:password, :password_confirmation)
  	end
end
