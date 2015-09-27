module UsersHelper 

  def gravatar_for(user, size=50)
  	gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
    image_tag(gravatar_url, alt: full_name(user), class: 'profile-pic')
  end

  def supervision_status(user)
    if current_user.supervises?(user)
      "Supervisee"
    elsif user.supervises?(current_user)
      "Supervisor"
    else
      nil
    end
  end  

  def concatenate_descriptions(grantholding, start_date, end_date, truncate=true)
    if grantholding
      logs_in_range = grantholding.user.timelogs_in_range(start_date, end_date)
      concat_allocations = concat_timelogs = []      
      logs_in_range.each do |timelog|
        timelog.time_allocations.each do |allocation|
          next unless allocation.to_grant?(grantholding.grant)
          concat_allocations << allocation.comments
        end
        concat_timelogs << timelog.comments
      end
      concat_all = concat_timelogs + concat_allocations
      concat = concat_all.join(' ')
      if truncate
        concat[0, 19]
      else
        concat
      end
    else
      ""
    end
  end
end