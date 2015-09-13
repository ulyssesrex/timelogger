class TimelogsController < ApplicationController

  before_action :logged_in
  before_action :set_organization
  before_action :current_user_or_admin, 
    only: [:edit, :update, :destroy]
  before_action :find_timelog_by_id, 
    only: [:show, :edit, :update, :destroy]  
  before_action :find_timelogs_owner, 
    only: [:show, :index, :edit, :update, :destroy]    

  def new
    set_up_new_timelog_variables
  end

  def finish_from_button
    query_string = { 
      start_time:  params[:start_time], 
      finish_time: params[:finish_time] 
    }.to_query
    set_up_new_timelog_variables
    render js: %(window.location.href='#{new_user_timelog_path(@user)}?#{query_string}')
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
    @timelog = Timelog.new(timelog_params)
    @timelog.user = current_user
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
      current_user.admin? # then
      redirect_to user_path(current_user) and return 
    end
  end

  def index
    unless current_user?(@user) ||
       current_user.supervises?(@user) ||
       current_user.admin?
       redirect_to users_path and return
    end
    @timelogs = Timelog.where(user: @user.id)
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
        redirect_to users_path and return
      end
    end

    def find_timelog_by_id
      @timelog = Timelog.find(params[:id])
    end    

    def find_timelogs_owner
      @user = User.find(params[:user_id])
    end

    def set_up_new_timelog_variables
      @user = current_user
      @timelog = Timelog.new
      @user.grantholdings.each do |gh|
        @timelog.time_allocations.build(grantholding_id: gh.id)
      end
      if params[:start_time] && params[:finish_time]
        @start = parse_timestamp(params[:start_time])
        @end   = parse_timestamp(params[:finish_time])
      end
    end
end
