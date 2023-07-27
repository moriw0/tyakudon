module UsersHelper
  def avatar_for(user, options = { size: 32})
    if user.avatar.attached?
      size = options[:size]
      image_tag user.avatar.variant(resize_to_fill: [size, size]), class: 'avatar'
    else
      image_tag 'blank_user_image.png', class: 'avatar'
    end
  end

  def gravatar_for(user, options = { size: 80 })
    size         = options[:size]
    gravatar_id  = Digest::MD5.hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: 'gravatar')
  end
end
