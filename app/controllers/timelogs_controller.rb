class TimelogsController < ApplicationController
  before_action :find_timelog_by_id, only: [:show, :edit, :update, :destroy]  
  before_action :logged_in
  before_action :current_user_or_admin, only: [:edit, :update, :destroy]

  def new
    @user = current_user
    @timelog = Timelog.new
    if params[:start_time] && params[:finish_time]
      @start = parse_timestamp(params[:start_time])
      @end   = parse_timestamp(params[:finish_time])
    end
    @timelog.time_allocations.new
  end

  # def timer_start
  #   cookies[:start_time] = params[:start_time]
  #   respond_to do |format|
  #     format.js
  #   end
  # end

  def finish_from_button
    query_string = { 
      start_time:  params[:start_time], 
      finish_time: params[:finish_time] 
    }.to_query
    render js: %(window.location.href='#{new_timelog_path}?#{query_string}')
  end
  
  def create
    st = params[:timelog][:start_time]
    et = params[:timelog][:end_time]
    params[:timelog][:start_time] = convert_to_datetime(st)
    params[:timelog][:end_time]   = convert_to_datetime(et)
    if params[:timelog][:time_allocations_attributes]
      h = params[:timelog][:time_allocations_attributes][:hours]
      params[:timelog][:time_allocations_attributes][:hours] = convert_to_duration(h)
    end
    @timelog = current_user.timelog.new(timelog_params)
    @timelog.time_allocations.map! { |t| t.user_id = current_user.id }
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
            [:id, :hours, :comments, :_destroy]
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
