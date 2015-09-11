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
  
end
