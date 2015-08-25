class ChangeTimesheetToTimelog < ActiveRecord::Migration
  def change
  	remove_index  :timesheets, :user_id
  	rename_table  :timesheets, :timelogs
  	add_index     :timelogs,   :user_id

   	remove_index  :time_allocations, :timesheet_id
  	rename_column :time_allocations, :timesheet_id, :timelog_id
		add_index     :time_allocations, :timelog_id

  	

  end
end
