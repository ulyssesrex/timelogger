class GrantholdingsController < ApplicationController
  
  before_action :logged_in
  before_action :set_organization
  before_action :find_user
  
  def new
    @grants = Grant.all
  end

  # def add_grantholding_fields
  #   @user = User.find(params[:user_id])
  #   respond_to do |format|
  #     format.js
  #   end
  # end
  
  def create
    selected_grants = Grant.where("id IN (?)", params[:grant_ids])
    if selected_grants.none?
      flash[:danger] = "No grants selected."
      redirect_to new_user_grantholding_path(@user) and return
    elsif selected_grants.map { |index, grant| Grant.new(grant).save } # add index?
      grant_names = []
      selected_grants.each do |g|
        grant_names << g.name
      end
      msg  = "#{grant_names.join('and ')} #{pluralize_was(grant_names.count)} "
      msg += "added to your grants." 
      flash[:success] = msg
      redirect_to edit_user_path(@user) and return
    else
      @grants = Grant.all
      render 'new'
    end
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
    if @grantholding.update(grantholding_params)
      msg = "Your info for #{@grantholding.grant.name} was updated."
      flash[:success] = msg
      redirect_to user_grantholdings_path(@user) and return
    else
      render 'edit' and return
    end
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

  def pluralize_was(count)
    count > 1 ? 'were' : 'was'
  end
end
