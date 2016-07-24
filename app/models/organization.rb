class Organization < ActiveRecord::Base
  attr_accessor :reset_token, :password_digest
  
  has_many :users,   dependent: :destroy
  has_many :grants,  dependent: :destroy
    
  validates :name,     presence: true
  validates :password, length: { minimum: 6 }, 
                       allow_blank: true
  
  has_secure_password
  validates_confirmation_of :password
  accepts_nested_attributes_for :users
  
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  def grant_admin_status_to(user)
    user.create_activation_digest
    user.update(
      organization_id: self.id, 
      admin: true
    )
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(
      reset_digest:  User.digest(reset_token),
      reset_sent_at: Time.zone.now
    )
  end

  def keyword_reset_expired?
    reset_sent_at < 2.hours.ago
  end
end
