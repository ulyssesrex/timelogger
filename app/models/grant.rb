class Grant < ActiveRecord::Base  
  acts_as_tenant :organization
  belongs_to     :organization
  has_many       :grantholdings, dependent: :destroy
  has_many       :users, through: :grantholdings     
  validates      :name, presence: true
end
