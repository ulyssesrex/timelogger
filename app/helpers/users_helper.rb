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
      in_range = grantholding.user.timelogs_in_range(start_date, end_date)
      concat = concat_gen = ''      
      in_range.each do |t|
        t.time_allocations.each do |ta|
          next unless ta.to_grant?(grantholding.grant)
          concat += (ta.description + ' ')
        end
        concat_gen += (t.comments + ' ')
      end
      if !concat_gen.empty?
        concat_gen = concat_gen.insert(0, "Overall: ")
      end
      concat += concat_gen
      if truncate
        concat_new = concat[0, 19] 
        if concat.length > 20
          concat_new + '...'
        else
          concat_new
        end
      end
    else
      ""
    end
  end
end
