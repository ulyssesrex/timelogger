class TimeAllocation < ActiveRecord::Base
  attr_accessor :user_id
  belongs_to :grantholding
  belongs_to :timelog

  def to_grant?(grant)
  	grantholding.grant == grant
  end
end