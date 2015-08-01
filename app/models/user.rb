class User < ActiveRecord::Base
  attr_accessor :remember_token, 
                :activation_token, 
                :reset_token,
                :organization_name,
                :organization_password
  
###---Callbacks---###

  acts_as_tenant :organization
  before_save    :downcase_email
  before_create  :create_activation_digest
  
###---Validations---###
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :first_name,      presence:    true
  validates :last_name,       presence:    true
  validates :email,           presence:    true,
                              length:      { maximum: 255 },
                              format:      { with: VALID_EMAIL_REGEX },
                              uniqueness:  { case_sensitive: false }
  validates :password,        length:      { minimum: 6 },
                              allow_blank: true
  validates :position,        presence:    true
  has_secure_password
  validates_confirmation_of :password
  
###---Association Logic---###

  belongs_to :organization
  
  has_many   :grantholdings
  
  has_many   :grants,        
             through: :grantholdings

  has_many   :timesheets  

  has_many   :initiated_supervisions, 
             foreign_key: :supervisee_id, 
             class_name:  "Supervision",
             dependent:   :destroy
  
  has_many   :non_initiated_supervisions, 
             foreign_key: :supervisor_id, 
             class_name:  "Supervision", 
             dependent:   :destroy
             
  has_many   :supervisors, 
             through:    :initiated_supervisions,     
             class_name: "User"
             
  has_many   :supervisees, 
             through:    :non_initiated_supervisions, 
             class_name: "User"
             
  accepts_nested_attributes_for :grantholdings, allow_destroy: true             
             
###---Instance Methods---###
  
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end
  
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  def supervises?(user)
    self.supervisees.include?(user)
  end
  
  def has_supervisees?
    !self.supervisees.empty?
  end
  
  def is_supervisee_of?(user)
    self.supervisors.include?(user)
  end
  
  def add_supervisor(desired_supervisor)
    initiated_supervisions.create(supervisor_id: desired_supervisor.id)
  end
  
  def delete_supervisor(supervisor)
    initiated_supervisions.find_by(supervisor_id: supervisor.id).destroy
  end
  
  def delete_supervisee(supervisee)
    non_initiated_supervisions.find_by(supervisee_id: supervisee.id).destroy
  end
  
  def send_user_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:  User.digest(reset_token),
                   reset_sent_at: Time.zone.now
    )
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  
  def feed
    supervisee_ids = "SELECT supervisee_id FROM supervisions
                      WHERE supervisor_id = :user_id"
    Timesheet.where("user_id IN (#{supervisee_ids})
                     OR user_id = :user_id", user_id: id)
  end
  
  def total_hours_worked(start, stop)
    total_seconds = 0
    timesheets.where(start_time: start..stop,
                     end_time:   start..stop
               )
    .each do |timesheet|
      total_seconds += (timesheet.end_time.to_i - timesheet.start_time.to_i)
    end
    total_seconds / 3600.0 # Gives time in hours.
  end
  
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
  
###---Class Methods---###  

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ?
           BCrypt::Engine::MIN_COST :
           BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

###---Private Methods---###
  
  private
    
    def downcase_email
      self.email = email.downcase
    end

end