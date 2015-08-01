class Grantholding < ActiveRecord::Base
  attr_readonly :grant_id
  attr_readonly :user_id
  
  belongs_to :grant
  belongs_to :user
  has_many   :time_allocations
    
  validates :grant, presence: true
  validates :user,  presence: true
  
  def total_time_allocated_since(date)
    user = self.user
    total = 0
    timesheets_in_range = user.timesheets.where("end_time > ?", date)
    timesheets_in_range.each do |t|
      total += t.total_time
    end
    total
  end
end
