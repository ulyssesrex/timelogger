class TimeAllocation < ActiveRecord::Base
  attr_accessor :user_id
  belongs_to :grantholding
  belongs_to :timelog, inverse_of: :time_allocations
end