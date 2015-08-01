module UsersHelper
  
  # Displays a custom Gravatar image link that identifies the user.
  def gravatar_for(user, options={size: 50})
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure/gravatar.com/avatar/#{gravatar_id}"
    image_tag(gravatar_url, alt: full_name(user), class: "gravatar")
  end
end
