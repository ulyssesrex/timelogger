class Timelog < ActiveRecord::Base

  belongs_to :user
  has_many   :time_allocations, inverse_of: :timelog
  has_many   :grantholdings,
             through: :time_allocations
             
  accepts_nested_attributes_for :time_allocations, allow_destroy: true
             
  validates  :user_id,    presence: true
  validates  :start_time, presence: true
  validates  :end_time,   presence: true
  validates_associated :time_allocations

  validate   :well_ordered_times
  validate   :allocate_no_more_than_timelog  

  # TODO: scope or default_scope?
  default_scope { order(end_time: :asc) }
  
  # In seconds or hours (float).
  def total_time(hours=false)
    total = end_time.to_i - start_time.to_i
    unless hours
      total
    else
      total / 3600.0
    end
  end
  
  private
  
  def well_ordered_times
    unless [end_time, start_time].include?(nil)
      error_msg = "start time must not be later than its end time"
      errors.add(:timelog, error_msg) if end_time < start_time
    end
  end

  def allocate_no_more_than_timelog
    sum = 0
    time_allocations.each do |t|
      sum += t.hours
    end
    unless sum <= total_time
      error_msg = "you can't allocate more hours than" 
      error_msg += " are on a timelog -- you listed #{sum}"
      error_msg += " but this timelog only has #{total_time}"
      errors.add(:timelog, error_msg)
    end
  end
end
