class TimesheetsController < ApplicationController
  before_action :find_timesheet_by_id,  except: [:new, :create]  
  before_action :logged_in
  before_action :current_user_or_admin, except: [:new, :create, :show]

  def new   
    @timesheet = Timesheet.new
    if session[:timesheet_start] && session[:timesheet_finish]
      @timesheet.start_time = session.delete(:timesheet_start)
      @timesheet.end_time   = session.delete(:timesheet_finish)
    end
  end

  def start_from_button # TODO: create these routes.
    session[:timesheet_start] = params[:timesheet_start]
    respond_to do |format|
      format.js
    end
  end

  def finish_from_button
    session[:timesheet_finish] = params[:timesheet_finish]
    respond_to do |format|
      format.js
    end
  end
  
  def create
    @timesheet = Timesheet.new(timesheet_params)
    unless current_user?(@timesheet.user) || current_user.admin?
      redirect_to user_path(current_user) and return
    end
    redirect_to user_path(current_user) if params[:commit] == "Cancel"    
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
