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

  has_many   :timelogs  

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
  
  def grants
    grantholdings.grants
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
    Timelog.where("user_id IN (#{supervisee_ids})
                     OR user_id = :user_id", user_id: id)
  end
  
  def total_hours_worked(start, stop)
    total_seconds = 0
    timelogs.where(start_time: start..stop,
                     end_time:   start..stop
               )
    .each do |timelog|
      total_seconds += (timelog.end_time.to_i - timelog.start_time.to_i)
    end
    total_seconds / 3600.0 # Gives time in hours.
  end

  # Returns '0:00' format of total hours user has worked on grant since date.
  def hours_worked_on_grant(since_date, grant_name)
    
    timelogs_in_range = self.timelogs.where('start_time >= ?', since_date)
    hours_worked = 0
    timelogs_in_range.each do |timelog|
      timelog.time_allocations.each do |ta|
        hours_worked += ta.hours if ta.to_grant?(grant_name)
      end
    end
    hours_worked
  end
  
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
  
###---Class Methods---###  

  # Returns string formatted version of float hours duration.
  def User.duration_to_hours_display(duration)
    duration = (duration * (60 * 60)).to_i
    h = m = s = 0
    h = (duration / (60 * 60)).to_s
    duration = duration % (60 * 60)
    m = (duration / 60).to_s
    duration = duration % 60
    s = duration.to_s
    "#{pad(h,3)}:#{pad(m,2)}:#{pad(s,2)}"
  end

  def User.convert_to_datetime(user_string, time=true)    
    dates = date_array(user_string)
    # Matches a four digit number in user string,
    # assigns it to year.
    fdigit_year = dates.find { |n| /\d{4}/ =~ n }
    year = fdigit_year || ("20" + dates.last.to_s).to_i
    hrs = min = sec = 0
    if time
      times = time_array(user_string)
      hrs, min, sec = times[0], times[1], times[2]
      # Convert hours to military time if needed.
      m = meridian(user_string)
      if hrs == 12 && m == "AM"
        hrs = 0 
      elsif hrs < 12 && m == "PM"
        hrs += 12
      end
    end
    # Determines order of year, month, and day from user string.
    if fdigit_year != dates[0]
      month, day = dates[0], dates[1]
    else
      month, day = dates[1], dates[2]
    end
    Time.new(year, month, day, hrs, min, sec)
  end

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

    # Pads a string with zeros up to total length 'amount'
    def pad(n_str, amount)
      l = n_str.length
      pad_length = amount - l
      if pad_length >= 0
        zeros = "0" * pad_length
        "#{zeros}#{n_str}"
      else
        "#{n_str}"
      end
    end

    # Returns all numbers separated by ':'s
    def time_array(user_string)
      user_string.scan(/\d+(?=:)|(?<=:)\d+/).flatten.compact.map!(&:to_i)
    end

    # Matches all numbers separated by '-'s or '/'s
    def date_array(user_string)
      user_string.scan(/\d+(?=-)|(?<=-)\d+|\d+(?=\/)|(?<=\/)\d+/)
    end

    # Matches 'AM', 'PM', or variants thereof.
    def meridian(user_string)
      user_string[/a\.*m\.*|p\.*m\.*/i].tr('.', '').upcase
    end
end