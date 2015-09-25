class GrantsController < ApplicationController
  
  before_action :logged_in
  before_action :set_organization
  before_action :set_grant, only: [:edit, :update, :destroy]
  before_action :admin
    
  def new
    @grant = Grant.new
  end
  
  def create
    @grant = Grant.new(grant_params)
    if @grant.save
      flash[:success] = "Grant created."
      redirect_to grants_path and return
    else
      render 'new'
    end
  end
  
  def index
    @grants = Grant.all
    @organization = Organization.take
  end
  
  def edit
  end
  
  def update
    # unless params[:commit] == "Cancel"
      if @grant.update(grant_params)
        flash[:success] = "Grant updated."
        redirect_to grants_path and return
      else
        render 'edit'
      end
    # else
    #   redirect_to grants_path and return
    # end
  end
  
  def destroy
    @organization = Organization.find(@grant.organization_id)
    @grant.destroy
    flash[:success] = "Grant deleted."
    redirect_to grants_path
  end
  
  private
  
  def grant_params
    params.require(:grant).permit(:name, :comments, :organization_id)
  end
  
  def set_grant
    @grant = Grant.find_by(params[:id])
  end
  
  def current_organization
    ActsAsTenant.current_tenant
  end
end
