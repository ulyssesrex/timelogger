class KeywordResetsController < ApplicationController

	before_action :find_organization,  only: [:edit, :update]
	before_action :valid_org_scenario, only: [:edit, :update]
	before_action :check_expiration,   only: [:edit, :update]

  def new
  	# Form for admin's email address.
  end

  def create
  	@admin = User.find_by(email: params[:keyword_reset][:email].downcase)
  	@organization = @admin.organization
  	if @admin && @organization
  		@organization.create_reset_digest
  		@admin.send_keyword_reset_email(@organization)
  		msg  = "Email sent with instructions on how "
      msg += "to reset keyword for #{@organization.name}."
      flash[:info] = msg
      redirect_to root_url and return
    else
    	flash.now[:danger] = "Email address not found."
    	render 'new'
    end
  end

  def edit
  	# Form for new organization keyword, keyword confirmation.
  	@reset = params[:id]
  end

  def update
  	@admin = User.find_by(email: params[:email])
    if params[:organization][:password].blank?
      flash.now[:danger] = "Keyword can't be blank."
      render 'edit' and return
    elsif @organization.update_attributes(keyword_params)
      log_in @admin
      flash[:success] = "Keyword has been reset. Notify users accordingly."
      redirect_to user_path(current_user) and return
    else
      render 'edit'
    end
  end

  private

  	def find_organization
  		@organization = User.find_by(email: params[:email]).organization
  	end

  	def valid_org_scenario
  		unless
  			@organization && @organization.authenticated?(params[:id])
  			redirect_to root_url  			
  		end  		
  	end

    def check_expiration
      if @organization.keyword_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_keyword_reset_url
      end
    end

  	def keyword_params
  		params.require(:organization).permit(:password, :password_confirmation)
  	end
end
