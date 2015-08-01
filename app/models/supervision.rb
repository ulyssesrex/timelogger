class Supervision < ActiveRecord::Base
  validates :supervisor_id, presence: true
  validates :supervisee_id, presence: true
  
  belongs_to :supervisor, class_name: "User"
  belongs_to :supervisee, class_name: "User"
end
