class GrantholdingsController < ApplicationController
  
  before_action :logged_in
  before_action :set_organization
  before_action :find_user
  
  def new
    @grantholding = Grantholding.new
    @grants = Grant.all
  end
  
  def create
    # unless params[:commit] == "Cancel"
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
    # else
    #   redirect_to user_grantholdings_path(@user)
    # end
  end
  
  def index
    @grantholdings = Grantholding.where(user_id: @user.id)
  end

  def show
    @grantholding = Grantholding.find(params[:id])
  end
  
  def edit
    @grantholding = Grantholding.find(params[:id])
  end
  
  def update
    @grantholding = Grantholding.find(params[:id])
    # unless params[:commit] == "Cancel"
      if @grantholding.update(grantholding_params)
        msg = "Your info for #{@grantholding.grant.name} was updated."
        flash[:success] = msg
        redirect_to user_grantholdings_path(@user) and return
      else
        render 'edit' and return
      end
    # else
    #   redirect_to user_grantholdings_path(@user) and return      
    # end
  end
  
  def destroy
    @grantholding = Grantholding.find(params[:id])
    @grantholding.destroy
    msg  = "#{@grantholding.grant.name} has been "
    msg += "removed from your grants."
    flash[:success] = msg
    redirect_to user_grantholdings_path(@user)
  end
  
  private
  
  def grantholding_params
    params.require(:grantholding).permit(:required_hours, :user_id, :grant_id)
  end

  def find_user
    @user = User.find(params[:user_id])
  end
end
