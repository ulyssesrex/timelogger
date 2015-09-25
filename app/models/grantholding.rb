class Grantholding < ActiveRecord::Base
  attr_readonly :grant_id
  attr_readonly :user_id
  
  belongs_to :grant
  belongs_to :user
  has_many   :time_allocations
    
  validates :grant_id, presence: true
  validates :user_id,  presence: true

  # A grant can't be associated with a user more than once.
  validates :grant_id, uniqueness: { scope: :user_id }

  # Returns '0:00' format of total hours user has worked on grant 
  # from since_date to end_date (type=Time).
  def hours_worked_from(since_time, end_time)    
    since_time   = since_time.to_time
    end_time     = end_time.to_time
    hours_worked = 0
    user.timelogs_in_range(since_time, end_time).each do |timelog|
      timelog.time_allocations.each do |ta|
        next unless ta.to_grant?(self.grant)
        hours_worked += ta.hours
      end
    end
    hours_worked
  end  
end
