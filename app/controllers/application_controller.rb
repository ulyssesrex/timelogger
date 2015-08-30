class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  protect_from_forgery with: :exception    
  include ApplicationHelper
  include SessionsHelper

  # after_action :check_for_timer_activation
    
  ###-----Before actions-----###

  # # Persists activated timer from time of mouse click
  # # through page refreshes.
  # def check_for_timer_activation
  #   if session[:timelog_start]
  #     render file: "/app/views/timelogs/start_from_button.js"
  #   end
  # end

  # Through 'acts_as_tenant' gem,
  # limits all SQL queries to current_user's organization.
  def set_organization
    current_organization = Organization.find(current_user.organization_id)
    set_current_tenant(current_organization)
  end
  
  # Redirects to user page if user doesn't have admin status.
  def admin
    unless current_user.admin?
      flash[:danger] = "Sorry, you must be an admin to do that."
      redirect_to user_path(current_user)
    end
  end
  
  # Redirects to login page if user isn't logged in.
  def logged_in
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_path
    end
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

  private
  
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
end
