class OrganizationsController < ApplicationController
  before_action :logged_in,        only: [:show, :edit, :update, :destroy]
  before_action :admin,            only: [:edit, :update, :destroy]
  before_action :set_organization, only: [:show, :edit, :update, :destroy]
    
  def new
    @organization = Organization.new
    user = @organization.users.build
  end
  
  def create
    # Cancel -->
    if params[:commit] == "Cancel"
      redirect_to root_url and return
      
    # Submit -->
    else
      @organization = Organization.new(organization_params)
      if @organization.save
        @admin = @organization.users.first
        @organization.grant_admin_status_to(@admin)
        UserMailer.organization_activation(@organization, @admin).deliver_now   
        msg  = "#{@organization.name} was created."
        msg += "Please check your email to activate your account."    
        flash[:success] = msg
        redirect_to root_url and return
      else
        render 'new'
      end
    end
  end
  
  def show
  end

  def edit
  end
  
  def update
    if @organization.update(organization_params)
      flash[:success] = "Your organization was successfully updated."
      redirect_to @organization and return
    else
      render 'edit'
    end
  end
  
  def destroy
    @organization.destroy
    flash[:success] = "#{@organization.name} successfully deleted."
    redirect_to root_url   
  end
  
  private
  
  def set_organization
    @organization = Organization.find(params[:id])
  end
  
  def organization_params
    params
      .require(:organization)
      .permit(:name, 
              :description, 
              :password, 
              :password_confirmation,
              users_attributes: [
                :first_name, 
                :last_name, 
                :position, 
                :email, 
                :password, 
                :password_confirmation
              ]
       )
  end
end