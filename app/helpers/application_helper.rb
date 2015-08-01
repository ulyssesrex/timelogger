module ApplicationHelper
  
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

end
