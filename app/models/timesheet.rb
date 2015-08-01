class Timesheet < ActiveRecord::Base
  belongs_to :user
  has_many   :time_allocations, inverse_of: :timesheet
  has_many   :grantholdings,
             through: :time_allocations
             
  accepts_nested_attributes_for :time_allocations, allow_destroy: true
             
  validates  :user_id,    presence: true
  validates  :start_time, presence: true
  validates  :end_time,   presence: true
  validate   :well_ordered_times
  
  # TODO: scope or default_scope?
  default_scope { order(end_time: :asc) }
  
  def total_time
    end_time - start_time
  end
  
  private
  
  def well_ordered_times
    unless [end_time, start_time].include?(nil)
      error_msg = "start time must not be later than its end time"
      errors.add(:timesheet, error_msg) if end_time < start_time
    end
  end
end
