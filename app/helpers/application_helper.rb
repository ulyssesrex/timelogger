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
      max = 7
    else
      max = 14
    end
    change = date > Date.today ? 0 : max
    date - change
  end
  
  def first_of_month
    Time.zone.today.beginning_of_month
  end

end
