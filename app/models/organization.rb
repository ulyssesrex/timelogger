class Organization < ActiveRecord::Base
  attr_accessor :reset_token, :activation_token
  
  has_secure_password

  has_many :users, dependent: :destroy
  has_many :grants, dependent: :destroy    

  validates :name, presence: true
  validates :password, allow_blank: true, length: { minimum: 6 }
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
    self.reset_token = Organization.new_token
    update_columns(
      reset_digest:  Organization.digest(reset_token),
      reset_sent_at: Time.zone.now
    )
  end

  def create_activation_digest
    self.activation_token  = Organization.new_token
    self.activation_digest = Organization.digest(activation_token)
  end

  def keyword_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def Organization.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ?
           BCrypt::Engine::MIN_COST :
           BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def Organization.new_token
    SecureRandom.urlsafe_base64
  end
end
