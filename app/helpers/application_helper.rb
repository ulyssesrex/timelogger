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
  def format_time(time, army_time=false)
    army_time ? time.strftime('%T') : time.strftime('%r')
  end

  def format_duration(float_hours, neg=false)
    dur = (float_hours * 3600).round
    h = (dur / 3600).floor
    dur -= h * 3600
    m = (dur / 60).floor
    dur -= m * 60
    s = dur
    if h.zero? && m.zero? && s.zero?
      display = "0 min"
    elsif h.zero? && m.zero?
      display = "< 1 min"
    else
      display = "#{h} hrs, #{m} min"
    end
  end

  def hours_to_seconds(float_hours)
    whole_hours_in_seconds = (float_hours.floor) * 3600
    remainder_in_seconds = ((float_hours - whole_hours) * 3600).round
    whole_hours_in_seconds + remainder_in_seconds
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

  # Returns float value of duration in hours.
  def convert_to_duration(hours_param)
    unless hours_param.nil?
      times_array = hours_param.split(":")
      hrs = times_array[0].to_f
      min = times_array[1].to_f
      sec = times_array[2].to_f
      min = min / 60
      sec = sec / (60 * 60)
      hrs += (min + sec)
    end
  end

  # def link_to_remove_fields(name, f)
  #   f.hidden_field(:_destroy) + link_to(name, "remove_fields(this)", class: 'remove-fields-link')
  # end
  
  # def link_to_add_fields(name, f, association)
  #   new_object = f.object.class.reflect_on_association(association).klass.new
  #   fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
  #     render(association.to_s.singularize + "_fields", :f => builder)
  #   end
  #   link_to(name, "add_fields(this, \"#{association}\", \"#{j(fields)}\")", class: 'add-fields-link')
  # end
end