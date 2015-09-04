class TimeAllocation < ActiveRecord::Base
  attr_accessor :user_id
  belongs_to :grantholding
  belongs_to :timelog, inverse_of: :time_allocations

  def to_grant?(grant_name)
  	grantholding.grant.name == grant_name
  end
end