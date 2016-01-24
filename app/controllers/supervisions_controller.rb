class SupervisionsController < ApplicationController
  
  before_action :logged_in
  before_action :set_organization
  
  def create
    @user = User.find(params[:user_id])
    @supervisor = User.find(params[:supervisor_id]) 
    @user.add_supervisor(@supervisor)
    flash[:success] = message_on_create @supervisor 
    redirect_to users_path
  end
  
  def destroy
    @user = User.find(params[:user_id])
    @other_user = User.find(params[:id])

    # If you're ending your boss' supervision of you:
    if @other_user.supervises?(@user)
      flash[:success] = message_on_delete(:supervisor)
      @supervision = @user.initiated_supervisions
                       .find_by(supervisor_id: @other_user.id)

    # If you're ending your supervision of your employee:                   
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
    "#{full_name(user, last_first=false)} is now listed as your supervisor."  
  end
  
  def message_on_delete(relationship_to_user)
    msg  = "#{full_name(@other_user, last_first=false)}"
    msg += " is no longer listed as your #{relationship_to_user}."
  end
end
  