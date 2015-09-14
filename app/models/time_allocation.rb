class TimeAllocation < ActiveRecord::Base
  attr_accessor :user_id
  belongs_to :grantholding
  belongs_to :timelog

  def to_grant?(grant_name)
  	grantholding.grant.name == grant_name
  end
  #TODO: what about grants that have the same name? Rewrite method and context.
end