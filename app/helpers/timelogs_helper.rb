module TimelogsHelper

	# Returns string formatted version of float hours duration.
  def duration_to_hours_display(duration)
    duration = (duration * (60 * 60)).to_i
    h = m = s = 0
    h = (duration / (60 * 60)).to_s
    duration = duration % (60 * 60)
    m = (duration / 60).to_s
    duration = duration % 60
    s = duration.to_s
    "#{pad(h,3)}:#{pad(m,2)}:#{pad(s,2)}"
  end

  def convert_to_datetime(user_string, contains_time=true)    
    # Match all numbers separated by '-'s or '/'s.
    dates = date_array(user_string)
    # Matches a four digit number in user string.
    four_digit_year = dates.find { |n| /\d{4}/ =~ n }
    # If no four digit numbers, prefix '20' to final match.
    year = four_digit_year || ("20" + dates.last.to_s).to_i
    hrs = min = sec = 0
    # If user string contains time,
    # match all numbers separated by ':'
    # and assign them to hrs, min, sec.
    if contains_time
      times = time_array(user_string)
      hrs, min, sec = times[0], times[1], times[2]
      # Find if user_string is 'AM' or 'PM' (no result returns nil).
      # If user_string uses 'PM' and non-military time, convert to 
      # parseable time by adding hours.
      m = meridian(user_string)
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

  # Returns Datetime object of last 'day' ('Monday', 'Sunday', etc.)
  def date_of_last(day, weeks=1)
    date  = Date.parse(day)
    delta = date < Date.today ? (7 * (weeks - 1)) : (7 * weeks)
    date - delta
  end

  # Returns all numbers separated by ':'s. Nil returns 0.
  def time_array(user_string)
    user_string.scan(/\d+(?=:)|(?<=:)\d+/).flatten.compact.map(&:to_i)
  end

  # Matches all numbers separated by '-'s or '/'s.
  def date_array(user_string)
    user_string.scan(/\d+(?=-)|(?<=-)\d+|\d+(?=\/)|(?<=\/)\d+/)
  end

  # Matches 'AM', 'PM', or variants thereof.
  def meridian(user_string)
    if m = user_string[/a\.*m\.*|p\.*m\.*/i]
      m.tr('.', '').upcase
    end
  end

  # Array of all days within start and end times.
  def days(start_time, end_time, newfirst=true)
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

  def digest(string)
    cost = ActiveModel::SecurePassword.min_cost ?
           BCrypt::Engine::MIN_COST :
           BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def new_token
    SecureRandom.urlsafe_base64
  end

	def day_display(day)
	  day.to_time.strftime("%a %b %e %Y")
	end

	def time_display(time)
		time.strftime("%l:%M:%S %p, %A %e %B %Y")
	end

end