class TimeAllocation < ActiveRecord::Base
  belongs_to :grantholding
  belongs_to :timesheet, inverse_of: :time_allocations
  
  validate :within_timesheet_range  
  
  def within_timesheet_range
    msg  = "start and end times must fall within its"
    msg += " associated timesheet's time range" 
    if
      start_time < timesheet.start_time ||
      end_time   > timesheet.end_time #-->
      errors.add(:time_allocation, msg)
    end
  end
end