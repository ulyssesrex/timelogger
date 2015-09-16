module UsersHelper 
  
  # def gravatar_for(user, options={size: 50})
  #   gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
  #   gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
  #   image_tag(gravatar_url, alt: full_name(user), class: "gravatar")
  # end

  # Displays a custom Gravatar image link that identifies the user.
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
end
