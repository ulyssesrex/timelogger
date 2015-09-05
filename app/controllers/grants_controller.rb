class GrantsController < ApplicationController
  before_action :set_organization, except: [:new, :create]
  before_action :logged_in
  before_action :set_grant, only:   [:show, :edit, :update, :destroy]
  before_action :admin,     except: [:show]
    
  def new
    @grant = Grant.new
  end
  
  def create
    @grant = Grant.new(grant_params)
    if @grant.save
      flash[:success] = "Grant created."
      redirect_to organization_path(@grant.organization_id) and return
    else
      render 'new'
    end
  end
  
  def show
    @grantholding = @grant.grantholdings.where(user: current_user)
  end
  
  def index
    @grants = Grant.all
  end
  
  def edit
  end
  
  def update
    if @grant.update(grant_params)
      flash[:success] = "Grant updated."
      redirect_to organization_path(@grant.organization_id) and return
    else
      render 'edit'
    end
  end
  
  def destroy
    @organization = Organization.find(@grant.organization_id)
    @grant.destroy
    flash[:success] = "Grant deleted."
    redirect_to organization_path(@organization.id)
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
