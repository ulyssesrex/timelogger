class Grantholding < ActiveRecord::Base
  attr_readonly :grant_id
  attr_readonly :user_id
  
  belongs_to :grant
  belongs_to :user
  has_many   :time_allocations
    
  validates :grant, presence: true
  validates :user,  presence: true
  
  # def time_allocated_since(datetime) # EDIT TO REFLECT 'HOURS' COLUMN INSTEAD OF END TIME
  #   time_allocated = 0
  #   time_allocations.where("end_time >= ?", datetime).each do |ta|
  #     if ta.start_time < datetime
  #       time_allocated += (ta.end_time - datetime)
  #     else
  #       time_allocated += ta.total_time
  #     end
  #   end
  #   time_allocated 
  # end 
end
