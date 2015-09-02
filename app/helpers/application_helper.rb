module ApplicationHelper
  require 'date'
  
  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "Timelogger"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end    
  end
  
  # Returns formatted version of user's name.
  # last_first option set to true yields "Smith, John"
  # if false, yields "John Smith"
  def full_name(user, last_first=true)
    if last_first
      "#{user.last_name}, #{user.first_name}"
    else
      "#{user.first_name} #{user.last_name}"
    end
  end
  
  # regular: 1:20:00 PM 
  # army_time: 13:20:00
  # amount: 02:05:01
  def format_time(time, options={})
    if options[:army_time]
      time.strftime('%r %p')
    elsif options[:regular] 
      time.strftime('%T')
    else options[:amount]
      secs  = time.to_i
      mins  = secs / 60
      hours = mins / 60
      # Proc pads numbers with zeros, if needed.
      # adj = Proc.new { |t| t.to_s.rjust(2, '0') }      
      if hours == 0 && mins == 0
        "#{secs}"
      else
        "#{hours} hrs, #{mins} min"
      end
    end
  end
  
  # regular: 2015-07-11 
  # verbose: Saturday, July 11, 2015
  def format_date(date, verbose=false)
    unless verbose
      date.strftime("%Y-%m-%d")
    else
      date.strftime("%A, %B%e, %Y")
    end      
  end
  
  def date_from_string(string)
    Date.parse(string)
  end
  
  def date_of_last(day, options={})
    date = Date.parse(day)
    unless options[:previous]
      change = 7
    else
      change = 14
    end
    change = (date > Date.today ? 0 : change)
    (date - change).to_time
  end
  
  def first_of_month
    Time.zone.today.beginning_of_month
  end

    # Converts a UNIX timestamp string to H:MM:SS AM/PM, M-D-YYYY
  def parse_timestamp(unix_timestamp)
    d = Time.at(unix_timestamp.to_i)
    d.strftime("%l:%M:%S %p, %-m-%e-%Y")
  end

  def convert_to_datetime(user_string)
    times = time_array(user_string)
    hrs, min, sec = times[0], times[1], times[2]
    dates = date_array(user_string)
    # Matches a four digit number in user string,
    # assigns it to year.
    fdigit_year = dates.find { |n| /\d{4}/ =~ n }
    year = fdigit_year || ("20" + dates.last.to_s).to_i
    # Convert hours to military time if needed.
    m = meridian(user_string)
    if hrs == 12 && m == "AM"
      hrs = 0 
    elsif hrs < 12 && m == "PM"
      hrs += 12
    end
    # Determines order of year, month, and day from user string.
    if fdigit_year != dates[0]
      month, day = dates[0], dates[1]
    else
      month, day = dates[1], dates[2]
    end
    Time.new(year, month, day, hrs, min, sec)
  end

  # Returns float value of duration in hours.
  def convert_to_duration(hours_param)
    times_array = hours_param.split(":")
    hrs = times_array[0].to_f
    min = times_array[1].to_f
    sec = times_array[2].to_f
    min = min / 60
    sec = sec / (60 * 60)
    hrs += (min + sec)
  end

  # Times are all numbers separated by ':'s
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
