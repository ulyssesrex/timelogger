class TimesheetsController < ApplicationController
  before_action :find_timesheet_by_id,  except: [:new, :create]  
  before_action :logged_in
  before_action :current_user_or_admin, except: [:new, :create, :show]

  def new
    # @user = User.find_by(id: params[:timesheet][:user_id])
    # unless current_user?(@user) || current_user.admin?
    #   redirect_to user_path(current_user) and return
    # end
    
    @timesheet = Timesheet.new
    @timesheet.start_time = params[:start_time]
    @timesheet.end_time   = params[:end_time]
  end
  
  def new_from_timer_button
    respond_to do |format|
      format.js { 
        redirect_to new_timesheet_path(
          start_time: params[:start_time], 
          end_time:   params[:end_time]
        )
      }
    end
  end
  
  def create
    @timesheet = Timesheet.new(timesheet_params)
    unless current_user?(@timesheet.user) || current_user.admin?
      redirect_to user_path(current_user) and return
    end    
    if @timesheet.save
      flash[:success] = "Timesheet was saved."
      redirect_to user_path(current_user) and return
    else
      render 'new'
    end
  end
  
  def show
    unless current_user?(@timesheet.user) || 
      current_user.supervisees.include?(@timesheet.user) || 
      current_user.admin? #-->
      redirect_to user_path(current_user) and return 
    end
  end
  
  def edit
  end
  
  def update
    if @timesheet.update_attributes(timesheet_params)
      flash[:success] = "Timesheet was updated."
      redirect_to user_path(current_user) and return
    else
      render 'edit'
    end    
  end
  
  def destroy
    @timesheet.destroy
    flash[:success] = "Timesheet deleted."
    redirect_to user_path(current_user)
  end
  
  private
  
    def timesheet_params
      params
        .require(:timesheet)
        .permit(:user_id, 
                :comments, 
                :start_time, 
                :end_time,
                time_allocations_attributes: 
                  [:start_time, :end_time, :comments]
                )
    end
    
    def current_user_or_admin
      unless current_user?(@timesheet.user) || current_user.admin?
        redirect_to user_path(current_user) and return
      end
    end
    
    def find_timesheet_by_id
      @timesheet = Timesheet.find(params[:id])
    end
end
