class TimeAllocation < ActiveRecord::Base
  belongs_to :grantholding
  belongs_to :timesheet, inverse_of: :time_allocations
  
  validate :within_timesheet_range  
  
  # The allocated hours cannot fall outside its timesheet's hours.
  # Adds errors to time allocation object if so.
  def within_timesheet_range
    msg  = "start and end times must fall within its"
    msg += " associated timesheet's time range" 
    if
      start_time < timesheet.start_time ||
      end_time   > timesheet.end_time #-->
      errors.add(:time_allocation, msg)
    end
  end
  
  # Returns total allocated time in seconds.
  def total_time
    end_time - start_time
  end
end