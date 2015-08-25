class TimelogsController < ApplicationController
  before_action :find_timelog_by_id, only: [:show, :edit, :update, :destroy]  
  before_action :logged_in
  before_action :current_user_or_admin, only: [:edit, :update, :destroy]

  def new
    @timelog = Timelog.new
    @timelog.start_time = params[:start_time]
    @timelog.end_time   = params[:finish_time]
    #@timelog ||= Timelog.new
  end

  # def timer_start
  #   cookies[:start_time] = params[:start_time]
  #   respond_to do |format|
  #     format.js
  #   end
  # end

  def finish_from_button
    query_string = { 
      start_time: params[:start_time], 
      finish_time: params[:finish_time] 
    }.to_query
    render js: %(window.location.href='#{new_timelog_path}?#{query_string}')
  end
  
  def create
    @timelog = Timelog.new(timelog_params)
    @timelog.user_id = current_user.id 
    if !current_user?(@timelog.user) || 
       !current_user.admin? ||
       params[:commit] == "Cancel" # then
       redirect_to user_path(current_user) and return
    end
    if @timelog.save
      flash[:success] = "Timelog was saved."
      redirect_to user_path(current_user) and return
    else
      render 'new' and return
    end
  end
  
  def show
    unless current_user?(@timelog.user) || 
      current_user.supervisees.include?(@timelog.user) || 
      current_user.admin? #-->
      redirect_to user_path(current_user) and return 
    end
  end
  
  def edit
  end
  
  def update
    if @timelog.update_attributes(timelog_params)
      flash[:success] = "Timelog was updated."
      redirect_to user_path(current_user) and return
    else
      render 'edit'
    end    
  end
  
  def destroy
    @timelog.destroy
    flash[:success] = "Timelog deleted."
    redirect_to user_path(current_user)
  end
  
  private
  
    def timelog_params
      params.require(:timelog)
        .permit(
          :user_id, 
          :comments, 
          :start_time, 
          :end_time,
          time_allocations_attributes: 
            [:start_time, :end_time, :comments]
        )
    end
    
    def current_user_or_admin
      unless current_user?(@timelog.user) || current_user.admin?
        redirect_to user_path(current_user) and return
      end
    end
    
    def find_timelog_by_id
      @timelog = Timelog.find(params[:id])
    end
end
