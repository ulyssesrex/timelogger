class GrantsController < ApplicationController
  before_action :set_organization, except: [:new, :create]
  before_action :logged_in
  before_action :set_grant, only:   [:show, :edit, :update, :destroy]
  before_action :admin,     except: [:show]
  
  # TODO: all root_url redirects here should go to organization page instead.
  
  def new
    @grant = Grant.new
  end
  
  def create
    @grant = Grant.new(grant_params)
    if @grant.save
      flash[:success] = "Grant created."
      redirect_to root_url and return
    else
      render 'new'
    end
  end
  
  def show
  end
  
  def index
    @grants = Grant.all
  end
  
  def edit
  end
  
  def update
    if @grant.update(grant_params)
      flash[:success] = "Grant updated."
      redirect_to root_url and return
    else
      render 'edit'
    end
  end
  
  def destroy
    @grant.destroy
    flash[:success] = "Grant deleted."
    redirect_to root_url
  end
  
  private
  
  def grant_params
    params.require(:grant).permit(:name, :comments, :organization_id)
  end
  
  def set_grant
    @grant = Grant.find_by(params[:id])
  end
end
