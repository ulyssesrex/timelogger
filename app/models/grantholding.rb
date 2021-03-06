class Grantholding < ActiveRecord::Base

  attr_readonly :grant_id
  attr_readonly :user_id
  
  belongs_to :grant
  belongs_to :user
  has_many   :time_allocations
    
  validates :grant_id, presence: true, uniqueness: { scope: :user_id }
  validates :user_id,  presence: true

  after_initialize :set_default_required_hours

  def set_default_required_hours
    self.required_hours ||= 0.0
  end

  # A grant can't be associated with a user more than once. 

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
