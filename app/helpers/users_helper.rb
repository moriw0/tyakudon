module UsersHelper
  def avatar_for(user, variant_size)
    if user.avatar.attached?
      case variant_size
      when :small
        image_tag user.avatar.variant(resize_to_limit: [33, 33]), class: 'small-avatar'
      when :middle
        image_tag user.avatar.variant(resize_to_limit: [80, 80]), class: 'avatar'
      end
    else
      case variant_size
      when :small
        image_tag 'blank_user_image.png', class: 'small-avatar'
      when :middle
        image_tag 'blank_user_image.png', class: 'avatar'
      end
    end
  end

  def gravatar_for(user, options = { size: 80 })
    size         = options[:size]
    gravatar_id  = Digest::MD5.hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: 'gravatar')
  end
end
