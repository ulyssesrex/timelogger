class GrantholdingsController < ApplicationController
  before_action :logged_in
  
  def new
    @grantholding = Grantholding.new
    @grants = Grant.all
  end
  
  def create
    @grantholding = Grantholding.new(grantholding_params)
    @grantholding.user_id = current_user.id
    if @grantholding.save
      msg  = "#{@grantholding.grant.name} "
      msg += "has been added to your grants." 
      flash[:success] = msg
      redirect_to user_path(current_user) and return
    else
      @grants = Grant.all
      render 'new'
    end
  end
  
  def index
    @user = current_user
    @grantholdings = Grantholding.where(user_id: current_user.id)
  end
  
  def edit
    @grantholding = Grantholding.find(params[:id])
  end
  
  def update
    @grantholding = Grantholding.find(params[:id])
    if @grantholding.update(grantholding_params)
      msg = "Your info for #{@grantholding.grant.name} was updated."
      flash[:success] = msg
      redirect_to grantholdings_path and return
    else
      render 'edit'
    end      
  end
  
  def destroy
    @grantholding = Grantholding.find(params[:id])
    @grantholding.destroy
    msg  = "#{@grantholding.grant.name} has been "
    msg += "removed from your grants."
    flash[:success] = msg
    redirect_to grantholdings_path
  end
  
  private
  
  def grantholding_params
    params.require(:grantholding).permit(:required_hours, :user_id, :grant_id)
  end
end
