class TimelogsController < ApplicationController

  before_action :logged_in
  before_action :set_organization
  before_action :find_timelog_by_id, 
    only: [:show, :edit, :update, :destroy]   
  before_action :find_timelogs_owner, 
    except: [:new]
  before_action :current_user_or_admin,
    only: [:edit, :update, :destroy]
  before_action :user_supervisor_or_admin,
    only: [:show, :index, :day_index]

  def new
    set_up_timelog_variables
  end

  def end_from_button
    query_string = { 
      start_time:  params[:start_time], 
      end_time:    params[:end_time] 
    }.to_query
    set_up_timelog_variables
    js_redirect_to(new_user_timelog_path(@user) + "?" + query_string)
  end
  
  def create
    # Convert Timelog start, end params to DateTime
    st = convert_to_datetime(params[:timelog][:start_time])
    et = convert_to_datetime(params[:timelog][:end_time])
    params[:timelog][:start_time] = st
    params[:timelog][:end_time]   = et
    # Convert each grant time allocation param to Float hours
    allocations_attributes = params[:timelog][:time_allocations_attributes].values
    if !allocations_attributes.empty?
      allocations_attributes.each do |hash|
        hash['hours'] = convert_to_duration(hash['hours'])
      end
      params[:timelog][:time_allocations_attributes] = allocations_attributes
    end
    # Create new Timelog instance
    @timelog = Timelog.new(timelog_params)
    @timelog.user_id = current_user.id
    # Redirect if creator's id isn't Timelog's user_id 
    # and creator also isn't an admin.
    unless current_user?(@timelog.user) || current_user.admin?
      redirect_to user_path(current_user) and return
    end
    # If Timelog is successfully saved, 
    if @timelog.save
      flash[:success] = "Timelog was saved."
      redirect_to user_path(current_user) and return
    else
      render 'new' and return
    end
  end
  
  def index
    @start_date_table = User.date_of_last('Monday', weeks=2).to_time
    @end_date_table   = Time.zone.now.to_time
    set_up_index_variables
  end

  def filter_index
    sd = params[:start_date_table]
    ed = params[:end_date_table]
    unless sd.blank?      
      @start_date_table = User.convert_to_datetime(sd, contains_time=false)
    else
      @start_date_table = User.date_of_last('Monday', weeks=2).to_time
    end
    unless ed.blank?
      @end_date_table = User.convert_to_datetime(ed, contains_time=false)
    else
      @end_date_table = Time.zone.now
    end
    @order = params[:order]
    set_up_index_variables
    respond_to { |format| format.js }
  end

  def day_index
    @user  = User.find(params[:user_id])
    @date  = Date.parse(params[:date])
    start  = @date.beginning_of_day
    endd   = @date.end_of_day
    @timelogs_on_day = @user.timelogs_in_range(start, endd)
    respond_to do |format|
      format.js
    end
  end
  
  def destroy
    @timelog.destroy
    flash[:success] = "Timelog deleted."
    redirect_to user_timelogs_path(user: @user)
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
            [:id, :hours, :comments, :grantholding_id, :_destroy]
        )
    end

    # Given nested grant allocation attribute params,
    # converts them into float duration and totals them. 
    def allocations_hrs_total(alloc_params)
      total = 0
      alloc_params.values.each do |v|
        grant_hrs = convert_to_duration(v['hours'])
        total += grant_hrs
      end
      total
    end
    
    def current_user_or_admin
      unless current_user?(@timelog.user) || current_user.admin?
        redirect_to users_path and return
      end
    end

    def user_supervisor_or_admin
      unless 
        current_user?(@user) ||
        current_user.supervises?(@user) ||
        current_user.admin?

        redirect_to users_path and return
      end
    end      

    def find_timelog_by_id
      @timelog = Timelog.find(params[:id])
    end    

    def find_timelogs_owner
      @user = User.find(params[:user_id])
    end

    def set_up_index_variables
      @timelogs = Timelog.where(user: @user.id)
      @grantholdings = @user.grantholdings
      if @order && @order == "oldfirst"
        @days = User.days(@start_date_table, @end_date_table, newfirst=false)
      else
        @days = User.days(@start_date_table, @end_date_table)
      end
    end

    def set_up_timelog_variables
      find_timelogs_owner
      @timelog = Timelog.new
      @user.grantholdings.each do |gh|
        @timelog.time_allocations.build(grantholding_id: gh.id)
      end
      @timelog.start_time, @timelog.end_time = params[:start_time], params[:end_time]
    end
end
