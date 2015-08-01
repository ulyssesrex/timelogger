class SupervisionsController < ApplicationController
  before_action :logged_in
  before_action :set_organization
  
  def create
    @user = User.find(params[:supervisor_id])    
    current_user.add_supervisor(@user)    
    flash[:success] = message_on_create @user  
    redirect_to users_path
  end
  
  def all_coworkers
    @users = User.where(activated: true)
  end
  
  def supervisees
    @supervisees = current_user.supervisees
  end
  
  def destroy
    @user = User.find(params[:id])
    if @user.supervises?(current_user)
      flash[:success] = message_on_delete(:supervisor)
      @supervision = @user.non_initiated_supervisions
                       .find_by(supervisee_id: current_user.id)
    elsif @user.is_supervisee_of?(current_user)
      flash[:success] = message_on_delete(:supervisee)
      @supervision = @user.initiated_supervisions
                       .find_by(supervisor_id: current_user.id)
    else
      flash[:danger] = "User relationship cannot be destroyed."
      redirect_to users_path and return
    end
    @supervision.destroy
    redirect_to users_path
  end
  
  private

  def message_on_create(user)
    "#{user.first_name} is now your supervisor."  
  end
  
  def message_on_delete(relationship_to_user)
    msg  = "#{full_name(@user, last_first=false)}"
    msg += " is no longer your #{relationship_to_user}."
  end
end
  