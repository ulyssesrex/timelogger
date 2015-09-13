class SupervisionsController < ApplicationController
  
  before_action :logged_in
  before_action :set_organization
  
  def create
    @user = User.find(params[:user_id])
    @supervisor = User.find(params[:supervisor]) 
    @user.add_supervisor(@supervisor)    
    flash[:success] = message_on_create @supervisor 
    redirect_to users_path
  end
  
  def supervisees
    @index = true
    @user  = User.find(params[:user_id])
    @supervisees  = @user.supervisees
    @supervisions = Supervision.where(supervisor: @user)
  end
  
  def destroy
    @user = User.find(params[:user_id])
    @other_user = User.find(params[:id])

    # If you're ending your boss' supervision of you:
    if @other_user.supervises?(@user)
      flash[:success] = message_on_delete(:supervisor)
      @supervision = @user.initiated_supervisions
                       .find_by(supervisor_id: @other_user.id)

    # If you're ending supervising your employee:                   
    elsif @other_user.is_supervisee_of?(@user)
      flash[:success] = message_on_delete(:supervisee)
      @supervision = @user.non_initiated_supervisions
                       .find_by(supervisee_id: @other_user.id)
                       
    else
      flash[:danger] = "Supervision can't be ended."
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
  