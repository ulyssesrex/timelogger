class TimeAllocation < ActiveRecord::Base
  belongs_to :grantholding
  belongs_to :timelog, inverse_of: :time_allocations
  
  # Returns total allocated time in seconds.
  def total_time
    end_time - start_time
  end
end