class TimeAllocation < ActiveRecord::Base
  belongs_to :grantholding
  belongs_to :timelog, inverse_of: :time_allocations
  
  validate :within_timelog_range  
  
  # The allocated hours cannot fall outside its timelog's hours.
  # Adds errors to time allocation object if so.
  def within_timelog_range
    msg  = "start and end times must fall within its"
    msg += " associated timelog's time range" 
    if
      start_time < timelog.start_time ||
      end_time   > timelog.end_time #-->
      errors.add(:time_allocation, msg)
    end
  end
  
  # Returns total allocated time in seconds.
  def total_time
    end_time - start_time
  end
end