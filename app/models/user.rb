class User < ActiveRecord::Base
  attr_accessor :remember_token, 
                :activation_token, 
                :reset_token,
                :organization_name,
                :organization_password
  
##### Callbacks

  acts_as_tenant :organization
  before_save    :downcase_email
  before_create  :create_activation_digest
  
##### Validations
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :first_name,      presence:    true
  validates :last_name,       presence:    true
  validates_uniqueness_to_tenant :email
  validates :email,           presence:    true,
                              length:      { maximum: 255 },
                              format:      { with: VALID_EMAIL_REGEX }
  validates :password,        allow_blank: true,
                              length:      { minimum: 6 }                              
  validates :position,        presence:    true
  has_secure_password
  validates_confirmation_of :password
  
##### Association Logic

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
             
##### Instance Methods
  
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
    g = []
    grantholdings.each do |gh|
      g << gh.grant
    end
    g
  end

  def supervises?(user)
    supervisees.include?(user)
  end
  
  def has_supervisees?
    !(self.supervisees.empty?)
  end
  
  def is_supervisee_of?(user)
    supervisors.include?(user)
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

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def send_keyword_reset_email(organization)
    UserMailer.keyword_reset(organization, self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(
      reset_digest:  User.digest(reset_token),
      reset_sent_at: Time.zone.now
    )
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
    start = start.to_time; stop = stop.to_time
    total_seconds = 0
    timelogs.where(start_time: start..stop, end_time: start..stop)
    .each do |timelog|
      total_seconds += (timelog.end_time.to_i - timelog.start_time.to_i)
    end
    total_hours = total_seconds / 3600.0
  end

  def allocated_time_from(start, stop)
    start = start.to_time
    stop  = stop.to_time
    allocated_time = 0
    grantholdings.each do |g|
      allocated_time += g.hours_worked_from(start, stop)
    end
    allocated_time
  end

  def unallocated_time_from(start, stop)
    start = start.to_time
    stop  = stop.to_time
    total_hours_worked(start, stop) - allocated_time_from(start, stop)
  end
  
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  def timelogs_in_range(start_time, end_time)
    timelogs.where(
      'start_time >= ?', start_time
    ).where(
      'end_time <= ?', end_time
    )
  end
  
##### Class Methods 

  # Returns string formatted version of float hours duration.
  def User.duration_to_hours_display(duration)
    duration = (duration * (60 * 60)).to_i
    h = m = s = 0
    h = (duration / (60 * 60)).to_s
    duration = duration % (60 * 60)
    m = (duration / 60).to_s
    duration = duration % 60
    s = duration.to_s
    "#{User.pad(h,3)}:#{User.pad(m,2)}:#{User.pad(s,2)}"
  end

  def User.convert_to_datetime(user_string, contains_time=true)    
    # Match all numbers separated by '-'s or '/'s.
    dates = User.date_array(user_string)
    # Matches a four digit number in user string.
    four_digit_year = dates.find { |n| /\d{4}/ =~ n }
    # If no four digit numbers, prefix '20' to final match.
    year = four_digit_year || ("20" + dates.last.to_s).to_i
    hrs = min = sec = 0
    # If user string contains time,
    # match all numbers separated by ':'
    # and assign them to hrs, min, sec.
    if contains_time
      times = User.time_array(user_string)
      hrs, min, sec = times[0], times[1], times[2]
      # Find if user_string is 'AM' or 'PM' (no result returns nil).
      # If user_string uses 'PM' and non-military time, convert to 
      # parseable time by adding hours.
      m = User.meridian(user_string)
      if hrs == 12 && m == "AM"
        hrs = 0 
      elsif hrs < 12 && m == "PM"
        hrs += 12
      end
    end
    # Determines where in user string the month and day are.
    if four_digit_year != dates[0]
      month, day = dates[0], dates[1]
    else
      month, day = dates[1], dates[2]
    end
    # Returns time object.
    Time.new(year, month, day, hrs, min, sec)
  end

  # Pads a string with zeros up to total length 'amount'
  def User.pad(n_str, amount)
    l = n_str.length
    pad_length = amount - l
    if pad_length >= 0
      zeros = "0" * pad_length
      "#{zeros}#{n_str}"
    else
      "#{n_str}"
    end
  end

  # Returns Datetime object of last 'day' ('Monday', 'Sunday', etc.)
  def User.date_of_last(day, weeks=1)
    date  = Date.parse(day)
    delta = date < Date.today ? (7 * (weeks - 1)) : (7 * weeks)
    date - delta
  end

  # Returns all numbers separated by ':'s. Nil returns 0.
  def User.time_array(user_string)
    user_string.scan(/\d+(?=:)|(?<=:)\d+/).flatten.compact.map(&:to_i)
  end

  # Matches all numbers separated by '-'s or '/'s.
  def User.date_array(user_string)
    user_string.scan(/\d+(?=-)|(?<=-)\d+|\d+(?=\/)|(?<=\/)\d+/)
  end

  # Matches 'AM', 'PM', or variants thereof.
  def User.meridian(user_string)
    if m = user_string[/a\.*m\.*|p\.*m\.*/i]
      m.tr('.', '').upcase
    end
  end

  # Array of all days within start and end times.
  def User.days(start_time, end_time, newfirst=true)
    start_date = start_time.to_date
    end_date   = end_time.to_date
    days = []
    if newfirst
      end_date.downto(start_date) { |d| days << d }  
    else
      start_date.upto(end_date) { |d| days << d }
    end
    days
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

##### Private Methods
  
  private
    
    def downcase_email
      self.email = email.downcase
    end

end